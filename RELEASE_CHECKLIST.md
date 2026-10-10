# Before sharing your configured build

- Replace/remove the five active demo pool rows and their example prices.
- Check category keys, labels, real classnames and vehicle-mod dependencies.
- Keep Heavy VTOL Transports and VTOL CAS independently configured.
- Set templateFilter.sqf if addon-managed pools/prices should apply only to selected rebel templates.
- Run tools/build.py --check, then build the final PBO.
- Verify the gameplay checks in TUTORIAL.md section 8, including a joining client.
- Distribute one copy of the vehicle-menu module; replace its old version when adopting this one.
- Sign the final PBO if your server uses signature verification.
- Keep the editable source, tutorial and origin notes with the shared package.

