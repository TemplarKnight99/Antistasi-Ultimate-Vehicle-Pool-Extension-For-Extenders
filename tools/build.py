#!/usr/bin/env python3
"""Validate and pack this standalone addon. Python 3.9+; no third-party packages."""
from __future__ import annotations

import argparse
import hashlib
import json
import struct
import sys
from pathlib import Path

from validation import ValidationError, validate_source


def pack(source: Path, destination: Path):
    prefix = (source / "$PBOPREFIX$").read_text(encoding="utf-8-sig").strip()
    files = sorted(
        (p for p in source.rglob("*") if p.is_file()
         and not any(part.startswith(".") for part in p.relative_to(source).parts)
         and p.name.lower() != "config.bin"),
        key=lambda p: p.relative_to(source).as_posix().lower(),
    )
    header = bytearray(b"\0" + struct.pack("<5I", 0x56657273, 0, 0, 0, 0))
    header += b"prefix\0" + prefix.encode() + b"\0\0"
    data = bytearray()
    names = set()
    for path in files:
        name = str(path.relative_to(source)).replace("/", "\\")
        if name.lower() in names:
            raise ValidationError(f"Duplicate PBO path: {name}")
        names.add(name.lower())
        payload = path.read_bytes()
        header += name.encode() + b"\0" + struct.pack("<5I", 0, 0, 0, 0, len(payload))
        data += payload
    header += b"\0" + struct.pack("<5I", 0, 0, 0, 0, 0)
    body = bytes(header + data)
    destination.parent.mkdir(parents=True, exist_ok=True)
    destination.write_bytes(body + b"\0" + hashlib.sha1(body).digest())
    return {"entries": len(files), "size_bytes": destination.stat().st_size,
            "sha256": hashlib.sha256(destination.read_bytes()).hexdigest()}


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--check", action="store_true", help="Validate source/data only; do not rebuild.")
    parser.add_argument("--output", type=Path, help="Optional absolute or relative output PBO path.")
    args = parser.parse_args()
    project = Path(__file__).resolve().parents[1]
    addon = project / "addons/vehicles"
    try:
        validation = validate_source(addon)
        print(f"Validated {validation['categories']} categories, {validation['configured_unique_classes']} configured classes and {len(validation['registered_functions'])} function paths.")
        if args.check:
            return 0
        destination = args.output or project / "@Antistasi_Vehicle_Pool_Extension/addons/avpe_vehicles.pbo"
        packed = pack(addon, destination)
        report = {
            "addon_version": "1.0.0", "source_checks": validation, "packed_pbo": packed,
            "pbo_format": "Uncompressed, unsigned, text config.cpp; prefix metadata and SHA-1 trailer.",
            "not_run": ["Arma 3 runtime/UI/purchases/server/JIP", "Full SQF compiler/VM", "Arma 3 Tools binarisation/signing"],
        }
        (project / "VALIDATION.json").write_text(json.dumps(report, indent=2) + "\n")
        print(f"Built {destination}: {packed['entries']} entries, {packed['size_bytes']:,} bytes.")
        print("Arma 3 gameplay testing and signing are separate from these source/package checks.")
        return 0
    except (OSError, ValidationError) as exc:
        print(f"BUILD FAILED: {exc}", file=sys.stderr)
        return 1


if __name__ == "__main__":
    sys.exit(main())

