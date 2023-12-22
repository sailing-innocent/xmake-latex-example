\ProvidesClass{njupre/njupre}[2023/10/02 class for sailing-innocent's NJU Pre]

% Package Loading
% ---------------
% based on beamer class
\LoadClass{beamer}

% Chinese Support
\RequirePackage{fontspec} % XeLaTeX
\RequirePackage[CJKchecksingle]{xeCJK} % XeCJK
\RequirePackage{CJKnumb} % 使用 CJK 数字

% Math Support
\RequirePackage{amsmath}
\RequirePackage{tikz}
\usetikzlibrary{shapes.symbols}	% 稍后定义 hint 环境所需
\usetikzlibrary{3d}
\RequirePackage{pgfplots}
\RequirePackage{pgfplotstable}

% Figure Support
\RequirePackage{graphicx}
\RequirePackage{subcaption}
\RequirePackage{float}

% Bibliography Support
\RequirePackage{cite}
\RequirePackage{booktabs}
\setbeamertemplate{bibliography item}[text]

% Theme Configuration
\renewcommand{\today}{\number\year .\number\month .\number\day }

\useinnertheme{rounded}
\useoutertheme{split}
\usecolortheme{whale}
\usefonttheme[onlymath]{serif}
% Itemize items: default (triangle), circle, square, ball
\setbeamertemplate{itemize items}[circle]
% Enumerate items: default, circle, square, ball
\setbeamertemplate{enumerate items}[circle]
% Outline: default, sections numbered, subsections numbered, circle, square, ball, ball unnumbered
\setbeamertemplate{sections/subsections in toc}[default]
% General blocks:
\setbeamertemplate{blocks}[rounded][shadow=true]
% Title page:
\setbeamertemplate{title page}[default][colsep=-4bp,rounded=true]
% Part page:
\setbeamertemplate{part page}[default][colsep=-4bp,rounded=true]
% Background
\pgfdeclareimage[width=\paperwidth,height=0.85\paperheight]{bg}{njupre/njubackground}
\setbeamertemplate{background}{\pgfuseimage{bg}}


% color
\definecolor{NJUPurple}{rgb}{0.28235, 0.28235, 0.62745}%设置主题颜色
\usecolortheme[RGB={106,0,95}]{structure}
\setbeamercolor{frametitle}{parent=subsection in head/foot}
\setbeamercolor{frametitle right}{parent=subsection in head/foot}

\pgfdeclarehorizontalshading[frametitle.bg,frametitle right.bg]{beamer@frametitleshade}{\paperheight}{%
  color(0pt)=(frametitle.bg);
  color(\paperwidth)=(frametitle right.bg)}

  \AtBeginDocument{
    \pgfdeclareverticalshading{beamer@topshade}{\paperwidth}{%
      color(0pt)=(bg);
      color(4pt)=(black!50!bg)}
  }
  % footline: author | title | date | framenumber
  \defbeamertemplate*{footline}{nju theme}{%
  \leavevmode%
  \hbox{%
  \begin{beamercolorbox}[wd=.2\paperwidth,ht=2.25ex,dp=1ex,center]{title in head/foot}%
    \usebeamerfont{author in head/foot}\insertshortauthor
  \end{beamercolorbox}%
  \begin{beamercolorbox}[wd=.25\paperwidth,ht=2.25ex,dp=1ex,center]{title in head/foot}%
    \usebeamerfont{author in head/foot}\insertshortdate
  \end{beamercolorbox}%
  \begin{beamercolorbox}[wd=.485\paperwidth,ht=2.25ex,dp=1ex,center]{title in head/foot}%
   \usebeamerfont{author in head/foot}{南京大学xx学院}
  \end{beamercolorbox}%
   \begin{beamercolorbox}[wd=0.065\paperwidth,ht=2.25ex,dp=1ex,right]{title in head/foot}%
    \insertframenumber{} / \inserttotalframenumber\hspace*{2ex}
  \end{beamercolorbox}}%
  \vskip0pt%
}

% headline
\defbeamertemplate*{headline}{nju theme}{%
  \leavevmode%
  \@tempdimb=6.4375ex%
    \pgfdeclareimage[height=.95\@tempdimb]{logo}{njupre/njulogo.png}%
    \pgfdeclareimage[height=1.\@tempdimb]{title_logo}{njupre/njuname.png}%
    \pgfdeclareimage[height=1.\@tempdimb]{school_logo}{njupre/school.png}%
  \logo{\pgfuseimage{logo}}%
  \ifdim\@tempdimb>0pt%
    \advance\@tempdimb by 1.125ex%
     \begin{beamercolorbox}[wd=.3\paperwidth,ht=\@tempdimb,center]{subsection in head/foot}%
      \vbox to\@tempdimb{\vfil\pgfuseimage{school_logo}\vfil}%
    \end{beamercolorbox}%
    \begin{beamercolorbox}[wd=.5\paperwidth,ht=\@tempdimb]{subsection in head/foot}%
      \vbox to\@tempdimb{\vfil\insertsectionnavigationhorizontal{.5\textwidth}{\hskip0pt 
      plus1filll}{}\vfil}
    \end{beamercolorbox}%
    \begin{beamercolorbox}[wd=.135\paperwidth,ht=\@tempdimb,center]{subsection in head/foot}%
      \vbox to\@tempdimb{\vfil\pgfuseimage{title_logo}\vfil}%
    \end{beamercolorbox}%
    \begin{beamercolorbox}[wd=.065\paperwidth,ht=\@tempdimb,center]{subsection in head/foot}%
      \vbox to\@tempdimb{\vfil\insertlogo\vfil\vfil}%
    \end{beamercolorbox}%
  \fi%
}


\defbeamertemplate*{frametitle}{nju theme}{%
  \nointerlineskip%
  \hbox{\leavevmode
    \advance\beamer@leftmargin by -12bp%
    \advance\beamer@rightmargin by -12bp %
    \beamer@tempdim=\textwidth%
    \advance\beamer@tempdim by \beamer@leftmargin%
    \advance\beamer@tempdim by \beamer@rightmargin%
    \hskip-\Gm@lmargin\hbox{%
      \setbox\beamer@tempbox=\hbox{\begin{minipage}[b]{\paperwidth}%
          \vbox{}\vskip-.75ex%
          \leftskip0.3cm%
          \rightskip= 0pt plus1fil \leavevmode
          \insertframetitle%
          \ifx\insertframesubtitle\@empty%
            \strut\par%
          \else
            \par{\usebeamerfont*{framesubtitle}{\usebeamercolor[bg]{framesubtitle}\insertframesubtitle}\strut\par}%
          \fi%
          \nointerlineskip
          \vbox{}%
          \end{minipage}}%
      \beamer@tempdim=\ht\beamer@tempbox%
      \advance\beamer@tempdim by 2pt%
      \begin{pgfpicture}{0mm}{0pt}{\paperwidth}{\beamer@tempdim}
        \usebeamercolor{frametitle right}
        \pgfpathrectangle{\pgfpointorigin}{\pgfpoint{\paperwidth}{\beamer@tempdim}}
        \pgfusepath{clip}
        \pgftext[left,base]{\pgfuseshading{beamer@frametitleshade}}
      \end{pgfpicture}
      \hskip-\paperwidth%
      \box\beamer@tempbox%
    }%
    \hskip-\Gm@rmargin%
  }%
}
% font
\setbeamerfont{title}{shape=\bfseries,size=\Large}
\setbeamerfont{author}{shape=\bfseries}\setbeamerfont{title}{shape=\bfseries,size=\Large}
\setbeamerfont{author}{shape=\bfseries}
\setCJKsansfont{HYXinRenWenSong 65W}
\setmainfont{TeX Gyre Pagella}
\setsansfont{TeX Gyre Pagella}
\renewcommand{\em}{\bfseries\CJKfamily{emfont}} % 强调

%command 
\newcommand{\sectionframe}[1]{\begin{frame}
  \begin{beamercolorbox}[wd=.6\paperwidth,ht=2.25ex,dp=1ex,center]{title in section}
      \Huge #1
  \end{beamercolorbox}
  \end{frame}}