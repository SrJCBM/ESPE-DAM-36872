from pathlib import Path

archivo = Path(__file__).resolve().parent.parent / 'main.tex'
original = archivo.read_text(encoding='utf-8-sig')
cuerpo = original[original.index(r'\section{Introducción}'):]
preambulo = r'''\documentclass[12pt,letterpaper]{article}
\usepackage[utf8]{inputenc}
\usepackage[T1]{fontenc}
\usepackage[spanish,es-tabla]{babel}
\usepackage[margin=2.54cm,headheight=15pt,headsep=12pt]{geometry}
\usepackage{mathptmx}
\usepackage{graphicx,float,array,booktabs,xcolor,enumitem,caption,listings}
\usepackage{setspace,fancyhdr,titlesec,tocloft,etoolbox}
\usepackage[authoryear,round]{natbib}
\usepackage{xurl}
\usepackage[hidelinks]{hyperref}
\hypersetup{pdftitle={Instalación y configuración del SDK de Flutter y Android Studio},
 pdfauthor={Julio Blacio, Kerly Chuqui, Josue Guayasamin}}
% Presentación de trabajo estudiantil APA 7. Los índices se añaden
% por solicitud del informe; no son un componente obligatorio de APA.
\doublespacing
\raggedright
\setlength{\parindent}{1.27cm}
\setlength{\parskip}{0pt}
\setcounter{secnumdepth}{0}
\pagestyle{fancy}
\fancyhf{}
\fancyhead[R]{\thepage}
\renewcommand{\headrulewidth}{0pt}
\renewcommand{\footrulewidth}{0pt}
\fancypagestyle{plain}{\fancyhf{}\fancyhead[R]{\thepage}\renewcommand{\headrulewidth}{0pt}}
\titleformat{\section}{\normalfont\normalsize\bfseries\centering}{}{0pt}{}
\titleformat{\subsection}{\normalfont\normalsize\bfseries\raggedright}{}{0pt}{}
\titleformat{\subsubsection}{\normalfont\normalsize\bfseries\itshape\raggedright}{}{0pt}{}
\titlespacing*{\section}{0pt}{\baselineskip}{0pt}
\titlespacing*{\subsection}{0pt}{\baselineskip}{0pt}
\titlespacing*{\subsubsection}{0pt}{\baselineskip}{0pt}
\setlist{leftmargin=1.27cm,itemsep=0pt,parsep=0pt,topsep=0pt}
\captionsetup{font=normalsize,labelfont=bf,textfont=it,labelsep=newline,
 justification=raggedright,singlelinecheck=false,position=top,skip=8pt}
\AtBeginEnvironment{tabular}{\singlespacing}
\renewcommand{\arraystretch}{1.15}
\setlength{\bibhang}{1.27cm}
\setlength{\bibsep}{0pt}
\renewcommand{\bibsection}{\clearpage\phantomsection\section*{Referencias}\addcontentsline{toc}{section}{Referencias}}
\addto\captionsspanish{%
 \renewcommand{\contentsname}{Índice de contenidos}%
 \renewcommand{\listfigurename}{Índice de figuras}%
 \renewcommand{\listtablename}{Índice de tablas}%
 \renewcommand{\figurename}{Figura}%
 \renewcommand{\tablename}{Tabla}}
\renewcommand{\cfttoctitlefont}{\hfill\normalsize\bfseries}
\renewcommand{\cftaftertoctitle}{\hfill}
\renewcommand{\cftloftitlefont}{\hfill\normalsize\bfseries}
\renewcommand{\cftafterloftitle}{\hfill}
\renewcommand{\cftlottitlefont}{\hfill\normalsize\bfseries}
\renewcommand{\cftafterlottitle}{\hfill}
\renewcommand{\cftfigpresnum}{Figura\space}
\renewcommand{\cftfigaftersnum}{.\space}
\setlength{\cftfigindent}{0pt}
\setlength{\cftfignumwidth}{2cm}
\renewcommand{\cfttabpresnum}{Tabla\space}
\renewcommand{\cfttabaftersnum}{.\space}
\setlength{\cfttabindent}{0pt}
\setlength{\cfttabnumwidth}{1.8cm}
\definecolor{codegray}{rgb}{.96,.96,.96}
\lstset{backgroundcolor=\color{codegray},basicstyle=\ttfamily\small,
 frame=single,breaklines=true,columns=fullflexible,keepspaces=true,
 showstringspaces=false,aboveskip=12pt,belowskip=12pt}
\newcommand{\autor}{Julio Blacio, Kerly Chuqui y Josue Guayasamin}
\newcommand{\docente}{Doris Karina Chicaiza Angamarca}
\newcommand{\fecha}{5 de octubre de 2026}
% Se admiten las imágenes en la raíz de Overleaf o en Fotos_Overleaf.
\newcommand{\captura}[1]{\includegraphics[width=\linewidth,height=10.5cm,keepaspectratio]{#1}}
\newcommand{\recuadro}[1]{\fbox{\begin{minipage}[c][4cm][c]{.94\linewidth}
 \centering\textbf{Evidencia pendiente}\par
 Guardar la captura como\par\texttt{\detokenize{#1}}\end{minipage}}}
\newcommand{\evidencia}[4]{%
 \begin{figure}[H]
 \caption{#2}\label{#3}
 {\centering\IfFileExists{#1}{\captura{#1}}{%
  \IfFileExists{Fotos_Overleaf/#1}{\captura{Fotos_Overleaf/#1}}{\recuadro{#1}}}\par}
 \noindent\textit{Nota.} #4
 \end{figure}}
\newcommand{\pendiente}{\textit{Por completar}}

\begin{document}
% Portada estudiantil: mismo tamaño de fuente, título centrado y en negrita.
\thispagestyle{fancy}
\begin{center}
\vspace*{3\baselineskip}
\textbf{Instalación y configuración del SDK de Flutter y Android Studio}\par
\vspace{\baselineskip}
\autor\par
Departamento de Ciencias de la Computación,\par
Universidad de las Fuerzas Armadas ESPE\par
36872 -- Desarrollo de Aplicaciones Móviles\par
\docente\par
\fecha\par
\end{center}
\clearpage
\tableofcontents
\clearpage
\phantomsection
\addcontentsline{toc}{section}{Índice de figuras}
\listoffigures
\clearpage
\phantomsection
\addcontentsline{toc}{section}{Índice de tablas}
\listoftables
\clearpage

'''

def cambiar(antes, despues):
    global cuerpo
    if antes not in cuerpo:
        raise ValueError('No se encontró el texto esperado: ' + antes[:100])
    cuerpo = cuerpo.replace(antes, despues)

cambiar(r'\cite{', r'\citep{')
cambiar('Documentar cada etapa con capturas', 'Documentar cada comprobación con capturas')
cambiar('Se estableció como primera etapa', 'Se estableció como primera comprobación')
cambiar('documentarán esta etapa', 'documentaron estas comprobaciones')
cambiar(r'\textbf{Estado del documento:} se preparó una base documental con espacios para las evidencias del proceso. Las versiones, salidas de comandos y resultados de ejecución deberán completarse con los datos obtenidos durante la práctica. Los criterios de verificación descritos no constituyen resultados observados.',
        'Se incorporaron evidencias de la configuración existente y de la verificación realizada en el equipo de Julio Blacio. Las capturas del instalador, del asistente inicial y del proyecto abierto en Android Studio quedaron pendientes de los integrantes del grupo. No se reconstruyeron capturas de una instalación anterior.')
cambiar('Se tomó Windows como sistema anfitrión para el procedimiento. La Tabla~\\ref{tab:entorno} se reservó para los datos reales del equipo; no se fijó una versión instalada sin evidencia.',
        'La Tabla~\\ref{tab:entorno} presentó el entorno verificado en el equipo de Julio Blacio. Estos datos correspondieron a ese equipo y no se atribuyeron a los demás integrantes del grupo.')
filas = {
 'Edición y versión de Windows': r'Windows 11 Home, compilación 10.0.26300.9550',
 'Procesador, arquitectura y memoria RAM': r'Intel Core i5-12500H; 64 bits; 15.69 GB de RAM utilizable',
 'Espacio disponible en disco': r'Aproximadamente 28 GB en C: al inicio de la revisión',
 'Versión de Git': r'2.51.1.windows.1',
 'Versión y canal de Flutter': r'3.44.5, canal estable',
 'Versión de Dart': r'3.12.2',
 'Versión de Android Studio': r'Compilación AI-261.23567.138.2611.15646644',
 'Ruta del SDK de Flutter': r'\path{C:\Users\jcbla\flutter\flutter}',
 'Ruta del SDK de Android y nivel de API': r'\path{C:\Users\jcbla\AppData\Local\Android\Sdk}; plataforma Android 36.1; emulador API 37',
 'Emulador o dispositivo físico': r'AVD Pixel\_8\_Pro; identificador \texttt{emulator-5580}',
 'Fecha real de ejecución': r'5 de octubre de 2026',
}
for nombre, valor in filas.items():
    cambiar(nombre + r' & \pendiente', nombre + ' & ' + valor)
cambiar('La Figura~\\ref{fig:previos} deberá mostrar los datos del sistema y la salida de la consulta, en una captura o composición legible.',
        'La Figura~\\ref{fig:previos} mostró las características consultadas y la versión de Git disponible.')
cambiar('En la Figura~\\ref{fig:sdkflutter} se deberá identificar el archivo descargado y la carpeta extraída, incluida la subcarpeta \\texttt{bin}. La versión del paquete deberá coincidir con el registro del entorno.',
        'En el equipo verificado, el SDK ya se encontraba instalado en \\path{C:\\Users\\jcbla\\flutter\\flutter}. La Figura~\\ref{fig:sdkflutter} mostró su estructura, incluida la subcarpeta \\texttt{bin}; esta evidencia acreditó la ubicación existente, sin representar la descarga original.')
cambiar('La Figura~\\ref{fig:androidsdk} deberá mostrar las pestañas de plataformas y herramientas con sus versiones y estado de instalación. Si el proyecto solicita otra versión, deberá registrarse esa dependencia y la modificación efectuada.',
        'La Figura~\\ref{fig:androidsdk} mostró el inventario real obtenido con \\texttt{sdkmanager --list\_installed}. Se seleccionaron las columnas de paquete y versión para facilitar su lectura. La captura incluyó las herramientas y plataformas instaladas, sin representar las pestañas del SDK Manager.')
cambiar('La Figura~\\ref{fig:plugins} documentará los complementos y la ruta seleccionada.',
        'La Figura~\\ref{fig:plugins} mostró el complemento de Flutter instalado. El registro de los complementos también identificó Dart; su versión se comprobó en el manifiesto instalado, fuera de esta captura.')
cambiar('flutter doctor -v\n', 'flutter doctor\nflutter doctor -v\n')
cambiar('La Figura~\\ref{fig:licencias} registrará el estado real de las licencias y la Figura~\\ref{fig:doctor} la salida del diagnóstico. No se debe transcribir una salida esperada como si procediera del equipo.',
        'La Figura~\\ref{fig:licencias} registró las licencias aceptadas y la Figura~\\ref{fig:doctor} presentó el resumen de \\texttt{flutter doctor}. El diagnóstico detallado con \\texttt{-v} se conservó en el registro de verificación.')
cambiar('La Figura~\\ref{fig:dispositivo} deberá relacionar el dispositivo activo con el identificador detectado. Se deberá indicar en la Tabla~\\ref{tab:entorno} cuál de las dos alternativas se utilizó.',
        'La Figura~\\ref{fig:dispositivo} relacionó el AVD disponible con el emulador Android detectado y la comprobación de aceleración. Se utilizó el dispositivo virtual registrado en la Tabla~\\ref{tab:entorno}.')
cambiar('Las Figuras~\\ref{fig:proyecto} y~\\ref{fig:ejecucion} se reservaron para el proyecto y su ejecución. Se debe registrar cualquier error que impida completar esta comprobación.',
        'En la revisión del equipo se creó el proyecto \\texttt{verificacion\_flutter}, se compiló el APK con \\texttt{flutter build apk --debug} y se instaló en el emulador. El inicio de la actividad devolvió \\texttt{Status: ok}, y una interacción cambió el contador de 0 a 1. La Figura~\\ref{fig:ejecucion} mostró la aplicación en ese estado. La Figura~\\ref{fig:proyecto} quedó reservada para el proyecto abierto en el IDE; la compilación por terminal no acreditó esa apertura.')

# Los rótulos se incorporan al índice automáticamente desde las leyendas.
figuras = {
 'figura01_requisitos.png': ('Revisión del equipo y disponibilidad de Git', 'Captura real de Windows Terminal obtenida en el equipo de Julio Blacio.'),
 'figura02_flutter_sdk.png': ('Ubicación y estructura del SDK de Flutter', 'La consulta mostró las carpetas del SDK existente; no documentó su descarga original.'),
 'figura03_path.png': ('Ruta de Flutter en la variable de entorno Path', 'Se consultó la entrada de Path y la ubicación del comando Flutter en una terminal nueva.'),
 'figura04_versiones.png': ('Comprobación de Flutter y Dart desde la terminal', 'Las consultas mostraron Flutter 3.44.5, Dart 3.12.2 y Git 2.51.1.windows.1.'),
 'figura05_android_studio.png': ('Instalación de Android Studio en Windows', 'Evidencia pendiente: incorporar una captura real del instalador proporcionada por un integrante del grupo.'),
 'figura06_setup_wizard.png': ('Configuración inicial de Android Studio', 'Evidencia pendiente: incorporar el resumen de componentes y la finalización del asistente inicial.'),
 'figura07_android_sdk.png': ('Plataformas y herramientas del SDK de Android', 'Se mostraron las columnas de paquete y versión del inventario instalado; se omitieron las columnas de descripción y ubicación.'),
 'figura08_plugins.png': ('Complemento de Flutter instalado en Android Studio', 'La captura mostró el complemento de Flutter instalado en el IDE. La presencia de Dart se verificó adicionalmente en los archivos del complemento.'),
 'figura09_licencias.png': ('Revisión de licencias del SDK de Android', 'La consulta confirmó que las licencias del SDK de Android estaban aceptadas.'),
 'figura10_doctor.png': ('Diagnóstico del entorno de desarrollo', 'La captura mostró el resumen de flutter doctor. La advertencia de Visual Studio correspondió al desarrollo de aplicaciones para Windows.'),
 'figura11_dispositivo.png': ('Dispositivo Android disponible para las pruebas', 'Se consultaron el AVD, los dispositivos conectados y la disponibilidad de aceleración del emulador.'),
 'figura12_proyecto.png': ('Proyecto Flutter abierto en Android Studio', 'Evidencia pendiente: incorporar el proyecto abierto, el archivo lib/main.dart y el dispositivo seleccionado en el IDE.'),
 'figura13_ejecucion.png': ('Prueba de ejecución de la aplicación en Android', 'Captura real de la aplicación en el emulador. El contador presentó el valor 1 después de una interacción.'),
}
import re
for fichero, (titulo, nota) in figuras.items():
    patron = r'\\evidencia\{' + re.escape(fichero) + r'\}\{[^{}]*\}\{([^{}]*)\}\{[^{}]*\}'
    cuerpo, cantidad = re.subn(patron, lambda m: r'\evidencia{' + fichero + '}{' + titulo + '}{' + m[1] + '}{' + nota + '}', cuerpo)
    if cantidad != 1:
        raise ValueError('No se encontró una única figura para ' + fichero)

cambiar('Se definieron los criterios de la Tabla~\\ref{tab:resultados} para evaluar el proceso. La columna de resultado deberá completarse únicamente después de revisar las evidencias.',
        'La Tabla~\\ref{tab:resultados} reunió las comprobaciones respaldadas por las capturas y los registros del equipo de Julio Blacio. La evidencia de apertura del proyecto en Android Studio quedó pendiente.')
cambiar(r'\begin{table}[H]\centering\small', r'\begin{table}[H]\centering')
resultados = {
 'Flutter y Dart & Los comandos devuelven sus versiones.': 'Verificado; Figura~\\ref{fig:versiones}',
 'Path & El ejecutable corresponde al SDK elegido.': 'Verificado; Figura~\\ref{fig:path}',
 'Android Studio & El IDE inicia y reconoce el proyecto Flutter.': 'IDE disponible; apertura del proyecto pendiente',
 'SDK y licencias & Herramientas disponibles y licencias aceptadas.': 'Verificado; Figuras~\\ref{fig:androidsdk} y~\\ref{fig:licencias}',
 'Diagnóstico & Sin errores que impidan desarrollar para Android.': 'Android validado; advertencia para Windows',
 'Dispositivo & Android aparece en la lista de dispositivos.': 'Verificado; Figura~\\ref{fig:dispositivo}',
 'Aplicación & Compila, se abre y responde a una interacción.': 'APK compilado; inicio correcto; contador en 1',
}
for fila, valor in resultados.items():
    cambiar(fila + r' & \pendiente', fila + ' & ' + valor)
cambiar(r'\textbf{Análisis por completar:} describir la relación entre el diagnóstico y la prueba de ejecución, las versiones utilizadas y las limitaciones encontradas. Si existieron advertencias, explicar su efecto sobre el objetivo Android. Una captura del IDE abierto, por sí sola, no acredita la compilación de la aplicación.',
        'El diagnóstico confirmó la disponibilidad de Flutter y de las herramientas Android. Se mantuvo una advertencia por componentes de C++ ausentes en Visual Studio, relacionados con aplicaciones de escritorio para Windows. La compilación e instalación del APK y la respuesta del contador acreditaron el funcionamiento de la aplicación Android. La apertura del proyecto Flutter en Android Studio requirió una evidencia adicional; las capturas disponibles no documentaron la instalación inicial del IDE.')
cambiar(r'\pendiente & \pendiente & \pendiente \\[1cm]' + '\n' + r'\pendiente & \pendiente & \pendiente \\[1cm]',
        r'Advertencia de Visual Studio en flutter doctor & Se contrastó su alcance con el objetivo de desarrollo para Android. & La compilación y ejecución de la aplicación Android finalizaron correctamente. \\' + '\n' + r'Faltaron capturas de instalación inicial y del proyecto en el IDE. & Se reservaron las Figuras 5, 6 y 12 para evidencias reales. & Pendiente de los integrantes del grupo. \\')
cambiar('La confirmación del funcionamiento del entorno quedó pendiente de las evidencias reales. Esta conclusión deberá actualizarse con el resultado de la compilación y ejecución, así como con las incidencias que se hayan registrado.',
        'La compilación del APK, su inicio en el emulador y el cambio del contador permitieron confirmar el funcionamiento del entorno Android en el equipo revisado. La instalación inicial de Android Studio y la apertura del proyecto en el IDE quedaron pendientes de documentación adicional.')
cambiar('Completar la matriz de resultados antes de afirmar que el entorno quedó operativo.',
        'Incorporar las capturas pendientes y comprobar que las evidencias de cada integrante correspondan a su propio entorno.')

inicio_ref = cuerpo.index(r'\begin{thebibliography}')
fin_ref = cuerpo.index(r'\end{thebibliography}', inicio_ref) + len(r'\end{thebibliography}')
referencias = r'''\begin{thebibliography}{4}
\bibitem[Android Developers(s. f.)]{androidinstall}
Android Developers. (s. f.). \textit{Install Android Studio}. Recuperado el 5 de octubre de 2026, de \url{https://developer.android.com/studio/install}

\bibitem[Flutter(s. f.-a)]{flutteride}
Flutter. (s. f.-a). \textit{Android Studio and IntelliJ}. Recuperado el 5 de octubre de 2026, de \url{https://docs.flutter.dev/tools/android-studio}

\bibitem[Flutter(s. f.-b)]{fluttermanual}
Flutter. (s. f.-b). \textit{Install Flutter manually}. Recuperado el 5 de octubre de 2026, de \url{https://docs.flutter.dev/install/manual}

\bibitem[Flutter(s. f.-c)]{flutterandroid}
Flutter. (s. f.-c). \textit{Set up Android development}. Recuperado el 5 de octubre de 2026, de \url{https://docs.flutter.dev/platform-integration/android/setup}
\end{thebibliography}'''
cuerpo = cuerpo[:inicio_ref] + referencias + cuerpo[fin_ref:]
cambiar(r'\citep{flutterandroid,flutteride}', r'\citep{flutteride,flutterandroid}')
inicio_anexo = cuerpo.index(r'\appendix')
cuerpo = cuerpo[:inicio_anexo] + r'''\clearpage
\appendix
\section{Apéndice}
\begin{center}\textbf{Incorporación de evidencias}\end{center}
Cada espacio reservado indicó el nombre del archivo PNG correspondiente a su figura. Para incorporar una captura en Overleaf, se debe subir el archivo con ese nombre a la misma carpeta de \texttt{main.tex} y recompilar. También se admitió la subcarpeta \texttt{Fotos\_Overleaf} para la organización local de las imágenes.

Las Figuras 5, 6 y 12 permanecieron pendientes. Los títulos, las notas y el índice identificaron cada evidencia; las capturas de terminal se conservaron sin encabezados de etapa, nombre del autor o NRC. El índice de figuras incluyó los espacios reservados y se actualizó automáticamente al recompilar el documento.
\end{document}
'''
# Las leyendas no terminan en punto en la presentación adoptada.
cuerpo = cuerpo.replace('Registro del entorno de trabajo.}', 'Registro del entorno de trabajo}')
cuerpo = cuerpo.replace('Matriz de verificación del entorno.}', 'Matriz de verificación del entorno}')
cuerpo = cuerpo.replace('Incidencias y acciones aplicadas.}', 'Incidencias y acciones aplicadas}')
archivo.write_text(preambulo + cuerpo, encoding='utf-8')
print('main.tex actualizado en el mismo archivo; 13 figuras y 4 referencias.')
