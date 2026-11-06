import json
import shutil
from pathlib import Path

source = Path("attachments")
destination = Path("docs/screenshots")
destination.mkdir(parents=True, exist_ok=True)
names = [
    "01-inicio", "02-registro", "03-listado", "04-busqueda",
    "05-edicion", "06-persistencia", "07-confirmacion-borrado",
    "08-borrado-deslizando", "09-lista-vacia",
]
manifest = json.loads((source / "manifest.json").read_text())
exported = set()
for test in manifest:
    for attachment in test.get("attachments", []):
        suggested = attachment.get("suggestedHumanReadableName", "")
        for name in names:
            if suggested.startswith(name):
                shutil.copyfile(source / attachment["exportedFileName"], destination / (name + ".png"))
                exported.add(name)
missing = set(names) - exported
if missing:
    raise RuntimeError(f"Missing screenshots: {sorted(missing)}")
print("Exported all nine screenshots.")
