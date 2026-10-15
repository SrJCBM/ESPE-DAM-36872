from pathlib import Path
import zipfile
root = Path(__file__).resolve().parents[1]
app = root / 'Aplicacion'
exclude = {'build', '.dart_tool', '.gradle', '.kotlin', '.idea'}
include = ['lib', 'android', 'web', 'test', 'pubspec.yaml', 'pubspec.lock', 'analysis_options.yaml', 'README.md']
with zipfile.ZipFile(root / 'Aplicacion_36872.zip', 'w', zipfile.ZIP_DEFLATED) as archive:
    for name in include:
        target = app / name
        paths = target.rglob('*') if target.is_dir() else [target]
        for path in paths:
            relative = path.relative_to(app)
            if path.is_file() and not (set(relative.parts) & exclude) and path.name != 'local.properties' and path.suffix != '.iml':
                archive.write(path, relative.as_posix())
with zipfile.ZipFile(root / 'Aplicacion_36872.zip') as archive:
    assert archive.testzip() is None
    assert archive.read('lib/main.dart') == (app / 'lib/main.dart').read_bytes()
    assert not any(set(Path(name).parts) & exclude for name in archive.namelist())
    print(f'Aplicacion: {len(archive.namelist())} archivos, {(root / "Aplicacion_36872.zip").stat().st_size / 1024:.1f} KB, sin caches')
with zipfile.ZipFile(root / 'Informe_Overleaf.zip') as archive:
    assert archive.testzip() is None
    assert archive.read('main.tex') == (root / 'Informe/main.tex').read_bytes()
    assert 'evidencias/menu_android.png' in archive.namelist()
    print(f'Informe: {len(archive.namelist())} archivos, {(root / "Informe_Overleaf.zip").stat().st_size / 1024:.1f} KB, fuente identica')
