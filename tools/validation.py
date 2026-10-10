"""Validate declarative SQF data and addon paths using only Python's standard library."""
from __future__ import annotations

import math
import re
from pathlib import Path


class ValidationError(ValueError):
    pass


class SQFArrayParser:
    """Read literal SQF arrays. SQF backslashes stay literal; "" escapes a quote."""
    def __init__(self, text: str, name: str):
        self.text = text
        self.name = name
        self.pos = 0

    def fail(self, message: str):
        line = self.text.count("\n", 0, self.pos) + 1
        raise ValidationError(f"{self.name}:{line}: {message}")

    def skip(self):
        while self.pos < len(self.text):
            if self.text[self.pos].isspace():
                self.pos += 1
            elif self.text.startswith("//", self.pos):
                end = self.text.find("\n", self.pos)
                self.pos = len(self.text) if end < 0 else end + 1
            elif self.text.startswith("/*", self.pos):
                end = self.text.find("*/", self.pos + 2)
                if end < 0:
                    self.fail("Unclosed block comment")
                self.pos = end + 2
            else:
                break

    def value(self):
        self.skip()
        if self.pos >= len(self.text):
            self.fail("Expected a value")
        char = self.text[self.pos]
        if char == "[":
            self.pos += 1
            result = []
            self.skip()
            if self.pos < len(self.text) and self.text[self.pos] == "]":
                self.pos += 1
                return result
            while True:
                result.append(self.value())
                self.skip()
                if self.pos >= len(self.text):
                    self.fail("Unclosed array")
                char = self.text[self.pos]
                self.pos += 1
                if char == "]":
                    return result
                if char != ",":
                    self.fail("Expected a comma between rows/values")
                self.skip()
                if self.pos < len(self.text) and self.text[self.pos] == "]":
                    self.fail("Remove the trailing comma before ]")
        if char == '"':
            self.pos += 1
            result = []
            while self.pos < len(self.text):
                char = self.text[self.pos]
                self.pos += 1
                if char == '"':
                    if self.pos < len(self.text) and self.text[self.pos] == '"':
                        self.pos += 1
                        result.append('"')
                    else:
                        return "".join(result)
                else:
                    result.append(char)
            self.fail("Unclosed string")
        for token, result in (("true", True), ("false", False)):
            if self.text.startswith(token, self.pos):
                end = self.pos + len(token)
                if end == len(self.text) or not (self.text[end].isalnum() or self.text[end] == "_"):
                    self.pos = end
                    return result
        match = re.match(r"[+-]?\d+(?:\.\d+)?(?:[eE][+-]?\d+)?", self.text[self.pos:])
        if match:
            token = match.group()
            self.pos += len(token)
            value = float(token) if any(c in token for c in ".eE") else int(token)
            if not math.isfinite(value):
                self.fail("Numeric value must be finite")
            return value
        self.fail("Use literal arrays, strings, numbers and true/false in data files")

    def parse(self):
        result = self.value()
        self.skip()
        if self.pos < len(self.text) and self.text[self.pos] == ";":
            self.pos += 1
            self.skip()
        if self.pos != len(self.text):
            self.fail("Unexpected text after the array")
        if not isinstance(result, list):
            self.fail("Data file must return an array")
        return result


def read_data(path: Path):
    return SQFArrayParser(path.read_text(encoding="utf-8-sig"), path.name).parse()


def require(condition, message):
    if not condition:
        raise ValidationError(message)


def number(value, minimum=0):
    return type(value) in (int, float) and math.isfinite(value) and value >= minimum


def delimiters(path: Path):
    """Catch broken strings/comments/brackets. This is not a full SQF compiler."""
    parser = SQFArrayParser(path.read_text(encoding="utf-8-sig"), path.name)
    text = parser.text
    stack = []
    close = {"]": "[", ")": "(", "}": "{"}
    while parser.pos < len(text):
        parser.skip()
        if parser.pos >= len(text):
            break
        char = text[parser.pos]
        if char == '"':
            parser.value()
            continue
        parser.pos += 1
        if char in "[({":
            stack.append(char)
        elif char in "])}":
            if not stack or stack.pop() != close[char]:
                parser.fail("Unbalanced delimiter")
    require(not stack, f"{path.name}: Unclosed delimiter")


def validate_source(addon: Path):
    data = addon / "data"
    categories = read_data(data / "vehicleCategories.sqf")
    pools = read_data(data / "vehiclePools.sqf")
    prices = read_data(data / "vehiclePrices.sqf")
    filters = read_data(data / "templateFilter.sqf")
    roots = read_data(data / "previewRoots.sqf")
    keys = set()
    labels = set()
    for row in categories:
        require(isinstance(row, list) and len(row) == 8, "Each category must have eight fields")
        key, label, tier, airport, price, cost, threat, assets = row
        require(isinstance(key, str) and re.fullmatch(r"[A-Za-z][A-Za-z0-9_]*", key),
                f"Invalid category key: {key!r}")
        require(key not in keys, f"Duplicate category key: {key}")
        require(isinstance(label, str) and label.strip(), f"{key}: Label must be nonempty")
        require(label not in labels, f"Duplicate category label: {label}")
        require(type(tier) is int and tier >= 0, f"{key}: Tier must be a nonnegative integer")
        require(type(airport) is bool, f"{key}: Airport flag must be true or false")
        require(number(price) and price > 0, f"{key}: Fallback price must be positive")
        require(number(cost) and number(threat), f"{key}: Cost and threat must be nonnegative numbers")
        require(isinstance(assets, list) and all(isinstance(x, str) and x for x in assets),
                f"{key}: Asset keys must be an array of strings")
        keys.add(key)
        labels.add(label)
    require(categories, "Define at least one category")
    memberships = set()
    for row in pools:
        require(isinstance(row, list) and len(row) == 2, "Pool rows must be [key, [classes]]")
        key, classes = row
        require(isinstance(key, str) and key in keys, f"Unknown pool category: {key!r}")
        require(isinstance(classes, list) and all(isinstance(x, str) and x for x in classes),
                f"{key}: Classnames must be nonempty strings")
        memberships.update((key, name.lower()) for name in classes)
    seen_prices = set()
    for row in prices:
        require(isinstance(row, list) and len(row) == 2, "Price rows must be [classname, price]")
        name, price = row
        require(isinstance(name, str) and name, "Price classname must be a nonempty string")
        require(number(price) and price > 0, f"{name}: Price must be positive")
        require(name.lower() not in seen_prices, f"Duplicate price classname: {name}")
        seen_prices.add(name.lower())
    require(all(isinstance(x, str) and x for x in filters), "Template filter must contain template IDs")
    require(all(isinstance(x, str) and x.startswith("\\") and x.endswith("\\") for x in roots),
            "Preview roots must start and end with a backslash")
    for path in [addon / "config.cpp", *sorted(addon.rglob("*.sqf"))]:
        delimiters(path)
    prefix = (addon / "$PBOPREFIX$").read_text(encoding="utf-8-sig").strip()
    require(prefix and not prefix.startswith("\\") and "/" not in prefix, "Invalid PBO prefix")
    config = (addon / "config.cpp").read_text()
    base_match = re.search(r'class Vehicles\s*\{\s*file\s*=\s*"([^"]+)"', config)
    require(base_match, "CfgFunctions Vehicles group/file was not found")
    default_folder = base_match.group(1).strip("\\")
    functions = []
    for match in re.finditer(r'class\s+(\w+)\s*\{([^{}]*)\};', config):
        name, body = match.groups()
        if name in ("CfgFunctions", "CfgPatches"):
            continue
        explicit = re.search(r'file\s*=\s*"([^"]+)"', body)
        virtual = explicit.group(1).strip("\\") if explicit else default_folder + "\\fn_" + name + ".sqf"
        require(virtual.startswith(prefix + "\\"), f"{name}: Function path is outside PBO prefix")
        relative = virtual[len(prefix)+1:].replace("\\", "/")
        require((addon / relative).is_file(), f"{name}: Missing registered script: {relative}")
        functions.append(name)
    referenced = set()
    for path in addon.rglob("*.sqf"):
        referenced.update(re.findall(r"\bAVPE_fnc_(\w+)", path.read_text()))
    require(referenced <= set(functions), f"Unregistered AVPE functions: {sorted(referenced - set(functions))}")
    require(not any("KSH_VEH" in p.read_text() or "\\x\\A3UE" in p.read_text()
                    for p in addon.rglob("*.sqf")), "Legacy namespace/path remains")
    return {
        "categories": len(categories), "configured_memberships": len(memberships),
        "configured_unique_classes": len({name for key, name in memberships}),
        "prices": len(prices), "registered_functions": sorted(functions), "prefix": prefix,
        "data_contracts_and_function_paths_valid": True,
        "sqf_and_config_delimiter_checks_passed": True,
    }

