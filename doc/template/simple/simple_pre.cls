\NeedsTeXFormat{LaTeX2e}
\ProvidesClass{simple/simple_pre}[2023/09/27 class for sailing-innocent's Chinese Pre]

% Package Loading
% ---------------
% based on beamer class
\LoadClass{beamer}

\RequirePackage{fontspec} % XeLaTeX
\RequirePackage[CJKchecksingle]{xeCJK} % XeCJK
\RequirePackage{CJKnumb} % 使用 CJK 数字

\RequirePackage{amsmath}
\usefonttheme[onlymath]{serif}
\renewcommand{\today}{\number\year .\number\month .\number\day }

\RequirePackage{graphicx}
\RequirePackage{float}
\RequirePackage{subcaption}

\RequirePackage{cite}
\RequirePackage{booktabs}


% Beamer Theme
% ------------

\usetheme{Dresden}
\usecolortheme{dove}
\usefonttheme{structureitalicserif} 

% color
\definecolor{NJUPurple}{rgb}{0.28235, 0.28235, 0.62745}%设置主题颜色

% theme
\useinnertheme{rectangles}
\useoutertheme{shadow}

% font
\setbeamerfont{title}{shape=\bfseries,size=\Large}
\setbeamerfont{author}{shape=\bfseries}\setbeamerfont{title}{shape=\bfseries,size=\Large}
\setbeamerfont{author}{shape=\bfseries}
\setCJKsansfont{HYXinRenWenSong 65W}
\setmainfont{TeX Gyre Pagella}
\setsansfont{TeX Gyre Pagella}
\renewcommand{\em}{\bfseries\CJKfamily{emfont}} % 强调

% bibliography
\setbeamertemplate{bibliography item}[text]

