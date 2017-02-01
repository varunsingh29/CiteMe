#! /bin/bash

# filename has list of urls from command line
# filename = "$1"

echo "Enter URL: "
read url
# while read -r url || [ -n "$url" ]
# do
    # Set mode to get content of page in HTML
    url="${url}?action=render"

    # curl in default mode to get source code
    # regex to scrap off html code
    curl $url | sed 's/<\/*[^>]*>//g' > scraped.txt

    # put citations before full stop in sentences - silly hack
    sed -i 's/\.\(\[[0-9]\+]\)\+/&&\./g' scraped.txt
    sed -i 's/\.\(\[[0-9]\+]\)\+\.//g' scraped.txt

    # remove all empty lines
    sed -i '/^$/d' scraped.txt

    # split file in lines with files named chunk.0001 chunk.0002 ..
    split --lines=1 --numeric-suffixes --suffix-length=4 scraped.txt chunk.

    # Run regex on all files and combine results
    IN_FILES=`find . -type f -name "chunk*" | sort`
    for file in $IN_FILES
    do
        # Find patterns and modify them one at a time
        grep -o '\(\. \)\?\([^\.]\|[0-9]*\.[0-9]\+\)*\(\[[0-9]\+]\)\+[^\.]*' $file >> inter.txt

        # If citations is present then proceed
        if grep -q '\[[0-9]\+]' inter.txt;
            then


                # Store all citation numbers in a var after removing []
                cite=`grep -o '\[[0-9]\+]' inter.txt |  sed 's/\(\[\|]\)//g'`

                #Remove '. ' if present in beg
                sed -i 's/\. //g' inter.txt

                # Remove matches from main text
                sed -i 's/\[[0-9]\+]//g' inter.txt

                # Append ~ around numbers and create a result file
                ptext=`cat inter.txt`
                ptext="~ $cite ~ $ptext"
                echo $ptext >> lines.txt
        fi
    done

    # cleanup directory
    rm chunk.*

    # Take queries
    echo "Chose type of query"
    echo "[1]: Get lines with citation X"
    echo "[2]: Get citations of a line"
    read choice

    case "$choice" in
        #   For queries of type 1
        1)  echo "Enter citation number: "
            echo $cite

            # Use cite shell variable in regex to search from result set
            cat lines.txt | grep ".* $cite .*" > final.txt

            # Remove all citation numbers from result
            sed -i 's/~.\+~//g' final.txt

            cat final.txt
            ;;

        #   For queries of type 2
        2)  echo "Enter string: "
            read str

            cat lines.txt | grep -o "$str" > final.txt

            cat final.txt | grep -o '~.~'
            ;;
    esac
# done < "$filename"





