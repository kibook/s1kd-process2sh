Riding_a_bicycle.sh: DMC-S1000DBIKE-AAA-D00-00-00-00AA-130A-A_004-00_en-US.XML
	xsltproc process2sh.xsl $< > $@

clean:
	rm -f Riding_a_bicycle.sh
