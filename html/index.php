<?php
// Tcl-nap project home page.
//
$headers = getallheaders();
?>
<HTML>

<!-- $Id: index.php,v 1.9 2002/08/07 08:06:49 dav480 Exp $ -->

<HEAD>
<TITLE>Tcl-nap Project</TITLE>
</HEAD>

<BODY bgcolor=#FFFFFF topmargin="0" bottommargin="0" leftmargin="0" rightmargin="0" marginheight="0" marginwidth="0">

<!-- top strip -->
<TABLE width="100%" border=0 cellspacing=0 cellpadding=2 bgcolor="737b9c">
  <TR>
    <TD><SPAN class=maintitlebar>&nbsp;&nbsp;

<a href="http://sourceforge.net">
<img src="http://sourceforge.net/sflogo.php?group_id=55616&amp;type=2"
width="125" height="37" border="0" alt="SourceForge.net Logo"></a>

| <A class=maintitlebar href="http://sourceforge.net/projects/tcl/"><B>SF Tcl</B></A>
| <A class=maintitlebar href="http://sourceforge.net/projects/tktoolkit/"><B>SF Tk</B></A>
| <A class=maintitlebar href="http://sourceforge.net/projects/blt/"><B>SF BLT</B></A>
| <A class=maintitlebar href="http://sourceforge.net/projects/tcl-nap/"><B>SF NAP</B></A>
    </TD>
  </TR>
</TABLE>
<!-- end top strip -->

<!-- center table -->
<TABLE width="100%" border="0" cellspacing="0" cellpadding="6" bgcolor="#FFFFFF" align="center">
  <TR>
    <TD>
      <H3 ALIGN=CENTER>Tcl-nap Project</H3>

      <P>
	This is the home page 
	(http://<?php print $headers[Host]; ?>/)
	for the <b>Tcl-nap</b> SourceForge Project.
	This project provides the <b>NAP</b> 
	<i>(n-dimensional array processor)</i> extension to
	  <a href="http://www.tcl.tk/">Tcl</a>.

      <p>
	<H4>Tcl-nap project resources at SourceForge:</H4>
      <ul>
	      <li> <a href="http://sourceforge.net/projects/tcl-nap/">Tcl-nap Project Summary</a>
	      <li> <a href="http://sourceforge.net/project/showfiles.php?group_id=55616">File
			Distributions</a>
	      <li> <a href="http://sourceforge.net/bugs/?group_id=55616">Bug Database</a>
	      <li> <a href="http://sourceforge.net/patch/?group_id=55616">Patch Manager</a>
	      <li> <a href="http://cvs.sourceforge.net/cgi-bin/viewcvs.cgi/tcl-nap/">Browse
			CVS Repository</a>
      </ul>
	<P>

	<H4>E-mail</H4>
      <ul>
	      <li> <a href="https://lists.sourceforge.net/lists/listinfo/tcl-nap-users">
			Mailing list for users of NAP</a>
	      <li> <a href="https://lists.sourceforge.net/lists/listinfo/tcl-nap-devel">
			Mailing list for developers of NAP</a>
	      <li> <a href="https://lists.sourceforge.net/lists/listinfo/tcl-nap-announce">
			Mailing list for announcements of new versions of NAP</a>
	      <li> <a href="http://sourceforge.net/users/dav480/">
			Harvey Davies</a> (main developer of NAP)
      </ul>

	<H4>Further documentation:</H4>
	  <ul>
	    <li> <A HREF="contents.html">NAP</A>
	    <li> <A HREF="http://www.dar.csiro.au/rs/Capshome.html">CAPS</A>
			(CSIRO project which spawned NAP)
	    <li> <A HREF="http://www.tcl.tk/">Tcl/Tk</a>
	  </ul>

    </TD>
  </TR>
</TABLE>
<!-- end center table -->

<P>
<TABLE width="100%" border="0" cellspacing="0" cellpadding="2" bgcolor="737b9c">
  <TR>
    <TD align="center"><FONT color="#ffffff" size=-2><SPAN class="titlebar">

	<b>Author:</b> <a href="http://sourceforge.net/users/dav480/">Harvey Davies</a>
	&nbsp; &nbsp; &nbsp;
	&copy; 2002, CSIRO Australia.
	&nbsp; &nbsp; &nbsp;
	<a href="http://www.csiro.au/legalnotices/disclaimer.html">Legal Notice and Disclaimer</a>
	<br>

	<b>CVS Version Details:</b> $Id: index.php,v 1.9 2002/08/07 08:06:49 dav480 Exp $

        </SPAN></FONT>
    </TD>
  </TR>
</TABLE>

</body>
</html>
