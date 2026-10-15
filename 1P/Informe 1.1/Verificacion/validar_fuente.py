from pathlib import Path
import re

raiz = Path(__file__).resolve().parent.parent
texto = (raiz / 'main.tex').read_text(encoding='utf-8')
figuras = re.findall(r'\\evidencia\{([^{}]+)\}\{([^{}]+)\}\{([^{}]+)\}', texto)
assert len(figuras) == 29, len(figuras)
assert len({f[2] for f in figuras}) == 29
etiquetas = {f[2] for f in figuras} | set(re.findall(r'\\label\{([^{}]+)\}', texto))
referencias = set(re.findall(r'\\ref\{([^{}]+)\}', texto))
assert referencias <= etiquetas, referencias - etiquetas
bibliografia = set(re.findall(r'\\bibitem\[[^\]]+\]\{([^{}]+)\}', texto))
citas = {c for grupo in re.findall(r'\\citep\{([^{}]+)\}', texto) for c in grupo.split(',')}
assert citas == bibliografia, (citas, bibliografia)
pendientes = [f[0] for f in figuras if not any(p.is_file() for p in [raiz / f[0], raiz / 'Fotos_Overleaf' / f[0]])]
assert not pendientes, pendientes
notas = re.findall(r'\\evidencia\{([^{}]+)\}\{[^{}]+\}\{[^{}]+\}\{[^{}]+\}\{([^{}]+)\}', texto)
assert len(notas) == 29
kerly = {'figura05_android_studio.png', 'figura06_setup_wizard.png', 'figura12_proyecto.png'}
assert all(origen == ('Josue Guayasamin' if nombre.startswith('Evidencias_Josue/') else 'Kerly Chuqui' if nombre in kerly else 'Julio Blacio') for nombre, origen in notas)
assert not re.search(r'permanecieron pendientes|qued[óo] pendiente|quedaron pendientes|capturas pendientes|Evidencia pendiente:', texto, re.I)
assert (raiz / 'Logo.png').is_file() and (raiz / 'DCCO.png').is_file()
pila = []
for accion, nombre in re.findall(r'\\(begin|end)\{([^{}]+)\}', texto):
    if accion == 'begin':
        pila.append(nombre)
    else:
        assert pila and pila.pop() == nombre, nombre
assert not pila, pila
for nombre in ['capturar_terminal.ps1', 'generar_capturas_terminal.ps1', 'guardar_ventana_terminal.ps1', 'generar_evidencias.mjs']:
    script = (raiz / 'Verificacion' / nombre).read_text(encoding='utf-8-sig')
    assert not re.search(r'VERIFICACION REAL|Equipo de Julio|\bETAPA\b|\(Imagen\)', script, re.I), nombre
assert r'\listoffigures' in texto and r'\listoftables' in texto
print('Revisión de fuente: 29 figuras, 29 imágenes disponibles, procedencia identificada, referencias y entornos coherentes.')
print('Esta revisión de fuente no sustituye una compilación LaTeX.')
