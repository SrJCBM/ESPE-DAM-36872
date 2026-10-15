from pathlib import Path
import re
root = Path(r'C:\Users\jcbla\Desktop\ESPE\Septimo Semestre\Aplicaciones Moviles\1P\Tarea 1.1\Informe')
path = root / 'main.tex'
source = path.read_text(encoding='utf-8-sig')
marker = r'\section{Representación del ejercicio 2}'
start = source.index(marker)
end = source.index(r'\end{singlespace}', start) + len(r'\end{singlespace}')
old_section = source[start:end]
flow = r'''\begin{tikzpicture}[
  font=\footnotesize,
  e2terminal/.style={draw,rounded corners,minimum width=1.4cm,
    minimum height=.5cm,align=center,inner sep=3pt},
  e2proceso/.style={draw,rectangle,text width=2.9cm,
    minimum height=.65cm,align=center,inner sep=4pt},
  e2decision/.style={draw,diamond,aspect=2,text width=1.5cm,
    align=center,inner sep=2pt},
  e2entrada/.style={draw,trapezium,trapezium left angle=75,
    trapezium right angle=105,text width=2cm,
    align=center,inner sep=4pt},
  e2flecha/.style={-{Stealth[length=2mm]}}
]
\node[e2terminal] (ini) {Inicio};
\node[e2proceso,below=4mm of ini] (init)
  {$pago\gets10$\\$total\gets0$\\$mes\gets1$};
\node[e2decision,below=5mm of init] (ciclo) {$mes\leq20$};
\node[e2entrada,below=6mm of ciclo] (mostrar)
  {Mostrar\\mes y pago};
\node[e2proceso,below=4mm of mostrar] (sum)
  {$total\gets total+pago$};
\node[e2proceso,below=4mm of sum] (dup)
  {$pago\gets pago\cdot2$\\$mes\gets mes+1$};
\node[e2entrada,text width=1.3cm,right=8mm of ciclo,yshift=-1.5cm]
  (sal) {Mostrar\\total};
\node[e2terminal,below=4mm of sal] (fin) {Fin};
\draw[e2flecha] (ini.south)--(init.north);
\draw[e2flecha] (init.south)--(ciclo.north);
\draw[e2flecha] (ciclo.south)--node[right]{Sí}(mostrar.north);
\draw[e2flecha] (mostrar.south)--(sum.north);
\draw[e2flecha] (sum.south)--(dup.north);
\draw[e2flecha] (ciclo.east)-|node[above,pos=.25]{No}(sal.north);
\draw[e2flecha] (sal.south)--(fin.north);
\draw[e2flecha] (dup.south)--++(0,-4mm)--++(-2.4cm,0)
  |- (ciclo.west);
\end{tikzpicture}'''
ns = r'''\begin{tikzpicture}[x=1cm,y=1cm,font=\small]
% Cabecera horizontal del ciclo para evitar texto vertical superpuesto.
\draw (0,0) rectangle (12,4.7);
\draw (0,3.8)--(12,3.8);
\node at (6,4.25) {$pago\gets10$; $total\gets0$};
\node at (6,3.5) {Para $mes=1$ hasta $20$};
\draw (.45,3.2)--(12,3.2);
\draw (.45,.8)--(.45,3.2);
\draw (.45,2.4)--(12,2.4);
\draw (.45,1.6)--(12,1.6);
\node at (6.225,2.8) {Mostrar mes y pago};
\node at (6.225,2) {$total\gets total+pago$};
\node at (6.225,1.2) {$pago\gets pago\cdot2$};
\draw (0,.8)--(12,.8);
\node at (6,.4) {Mostrar total};
\end{tikzpicture}'''
pattern = r'\\begin\{tikzpicture\}.*?\\end\{tikzpicture\}'
blocks = list(re.finditer(pattern, old_section, re.S))
assert len(blocks) == 2
new_section = old_section
for match, replacement in reversed(list(zip(blocks, [flow, ns]))):
    new_section = new_section[:match.start()] + replacement + new_section[match.end():]
updated = source[:start] + new_section + source[end:]
assert updated[:start] == source[:start]
assert updated[start + len(new_section):] == source[end:]
path.write_text(updated, encoding='utf-8')
(root / 'Correccion_Ejercicio_2.tex').write_text(new_section + '\n', encoding='utf-8')
print('Se actualizaron únicamente los dos dibujos TikZ del ejercicio 2.')
print('Bloque para Overleaf: Correccion_Ejercicio_2.tex')
