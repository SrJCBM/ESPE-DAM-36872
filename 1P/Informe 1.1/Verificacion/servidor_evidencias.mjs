import http from 'node:http';
import fs from 'node:fs/promises';
import path from 'node:path';
import {fileURLToPath} from 'node:url';
const root=path.dirname(fileURLToPath(import.meta.url));
http.createServer(async(req,res)=>{
 try{
  const relative=decodeURIComponent(new URL(req.url,'http://localhost').pathname).slice(1)||'index.html';
  const target=path.resolve(root,relative);
  if(!target.startsWith(root+path.sep)){res.writeHead(403);res.end();return;}
  const mime={'.html':'text/html; charset=utf-8','.png':'image/png','.jpg':'image/jpeg','.txt':'text/plain; charset=utf-8','.md':'text/plain; charset=utf-8'}[path.extname(target)]||'application/octet-stream';
  const body=await fs.readFile(target);
  res.writeHead(200,{'Content-Type':mime});res.end(body);
 }catch{res.writeHead(404);res.end('No encontrado');}
}).listen(8766,'127.0.0.1',()=>console.log('Evidencias disponibles en http://127.0.0.1:8766'));
