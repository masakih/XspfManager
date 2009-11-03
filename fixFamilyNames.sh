#!/bin/sh

INPUT='FamilyName.txt'
TEMP=$INPUT.tmp

cp ${INPUT} ${INPUT}.bak

awk '
{
	print
}
/ti/ {
	print
	gsub("ti","chi")
	print
}
/chi/ {
	print
	gsub("chi","ti")
	print
}
/si/ {
	print
	gsub("si", "shi")
	print
}
/shi/ {
	print
	gsub("shi", "si")
	print
}
/tu/ {
	print
	gsub("tu", "tsu")
	print
}
/tsu/ {
	print
	gsub("tsu", "tu")
	print
}
' ${INPUT} | sort -u > ${TEMP}

mv ${TEMP} ${INPUT}
