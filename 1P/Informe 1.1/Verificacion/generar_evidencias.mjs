import fs from 'node:fs/promises';
import path from 'node:path';
import {fileURLToPath} from 'node:url';
const root = path.dirname(fileURLToPath(import.meta.url));
const esc = value => String(value).replaceAll('&','&amp;').replaceAll('<','&lt;').replaceAll('>','&gt;');
const read = async name => (await fs.readFile(path.join(root,name),'utf8')).replace(/^\uFEFF/,'').trim();
const css = `*{box-sizing:border-box}body{margin:0;background:#fff;color:#15202b;font-family:Arial,sans-serif}main{padding:34px 40px;max-width:1300px;margin:auto}header{border-bottom:3px solid #175e46;padding-bottom:14px;margin-bottom:22px}.tag{font-size:13px;font-weight:bold;color:#175e46;letter-spacing:1px}h1{font-size:28px;margin:10px 0}p{font-size:15px;line-height:1.5;margin:8px 0}pre{font-family:Consolas,monospace;font-size:16px;line-height:1.55;white-space:pre-wrap;overflow-wrap:anywhere;padding:20px;background:#f3f5f5;border:1px solid #d5dcdb;margin:14px 0}table{border-collapse:collapse;width:100%;font-size:14px}th,td{border:1px solid #d5dcdb;padding:10px;text-align:left}th{background:#edf3ef}footer{border-top:1px solid #ccd5d1;margin-top:22px;padding-top:12px;font-size:13px;color:#42544d}a{color:#175e46}img{max-width:100%}`;
const doc = (title,body,source) => `<!doctype html><html lang="es"><meta charset="utf-8"><title>${esc(title)}</title><style>${css}</style><main>${body}<footer>Origen: ${esc(source)}. Salidas reales recogidas en el equipo y mostradas en esta página local para su captura.</footer></main></html>`;
const items = [
 ['equipo','Recursos del equipo y Git',['equipo.txt','git.txt'],'Consultas Win32_OperatingSystem, Win32_Processor, Win32_LogicalDisk y git --version'],
 ['sdk_flutter','Ubicación del SDK de Flutter',['carpeta_flutter.txt'],'Get-ChildItem sobre la carpeta real del SDK de Flutter'],
 ['path','Configuración de Path y ubicación de Flutter',['path_flutter.txt'],'Path del usuario y where.exe flutter'],
 ['versiones','Versiones de Flutter, Dart y Git',['versiones.txt'],'flutter --version, dart --version, git --version y where.exe flutter'],
 ['studio','Android Studio instalado',['android_studio.txt'],'Archivo product-info.json del Android Studio instalado'],
 ['plugins','Complementos Flutter y Dart instalados',['plugins_manifest.txt'],'META-INF/plugin.xml de los archivos JAR de los complementos instalados'],
 ['licencias','Estado de las licencias de Android',['licencias.txt'],'flutter doctor --android-licenses'],
 ['doctor','Diagnóstico completo de Flutter',['flutter_doctor.txt'],'flutter doctor -v'],
 ['dispositivos','Emulador y dispositivo Android detectado',['emuladores.txt','dispositivos.txt'],'flutter emulators, emulator -accel-check y flutter devices'],
 ['compilacion','Compilación, instalación e inicio en Android',['compilacion.txt','ejecucion.txt'],'flutter build apk --debug y comandos adb de instalación e inicio']
];
for(const [id,title,files,source] of items){
 const blocks=[];
 for(const file of files) blocks.push(`<p><strong>Registro: ${esc(file)}</strong></p><pre>${esc(await read(file))}</pre>`);
 if(id==='sdk_flutter') blocks.unshift('<p><strong>Carpeta consultada:</strong> C:\\Users\\jcbla\\flutter\\flutter</p>');
 if(id==='doctor') blocks.push('<p><strong>Interpretación:</strong> la advertencia de Visual Studio corresponde a aplicaciones de escritorio Windows. La comprobación de Android y sus licencias aparece correcta.</p>');
 await fs.writeFile(path.join(root,id+'.html'),doc(title,blocks.join(''),source));
}
const sdk=await read('sdk_paquetes.txt');
const rows=sdk.split(/\r?\n/).filter(line=>line.includes('|')&&!line.includes('Description')).map(line=>line.split('|').slice(0,3).map(v=>v.trim()));
const sdkBody='<p><strong>SDK:</strong> C:\\Users\\jcbla\\AppData\\Local\\Android\\sdk</p><p>Inventario de paquetes instalados, obtenido directamente de sdkmanager. Las columnas muestran el identificador, la versión del paquete y la descripción.</p><table><thead><tr><th>Paquete</th><th>Versión</th><th>Descripción</th></tr></thead><tbody>'+rows.map(row=>'<tr>'+row.map(v=>'<td>'+esc(v)+'</td>').join('')+'</tr>').join('')+'</tbody></table>';
await fs.writeFile(path.join(root,'sdk_android.html'),doc('Paquetes del SDK de Android',sdkBody,'sdkmanager --list_installed; columnas Path, Version y Description'));
const links=[...items.map(([id,title])=>[id,title]),['sdk_android','Paquetes del SDK de Android']];
await fs.writeFile(path.join(root,'index.html'),doc('Evidencias de configuración y funcionamiento','<p>Estas evidencias corresponden al estado actual del equipo. Los asistentes originales de instalación y descarga se documentarán con las capturas de los integrantes que realicen esas etapas.</p><ul>'+links.map(([id,title])=>`<li><a href="${id}.html">${esc(title)}</a></li>`).join('')+'</ul><p><a href="plugins_flutter.png">Pantalla real del complemento Flutter en Android Studio</a></p><p><a href="aplicacion_prueba.png">Captura real de la aplicación en Android</a></p>','Registros originales y capturas conservados en la carpeta Verificacion'));
console.log('Páginas de evidencias generadas.');
