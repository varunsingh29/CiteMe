#! /bin/bash

# filename has list of multiple urls
# filename = "$1"

echo "Enter URL: "
read url

# loop for reading multiple urls from file. Ignore otherwise
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

    # Find patterns and modify them one at a time
    grep -o '\(\. \)\?\([^\.]\|[0-9]*\.[0-9]\+\)*\(\[[0-9]\+]\)\+[^\.]*' scraped.txt > inter.txt

    # If citations is present then proceed
    len=1
    while grep -q '\[[0-9]\+]' inter.txt
    do
        # select top most line with citations
        str=`grep -o '\. \([^\.]\|[0-9]*\.[0-9]\+\)*\(\[[0-9]\+]\)\+[^\.]*' inter.txt | head -1`

        # Store all citation numbers in a var after removing []
        cite=`echo $str | grep -o '\[[0-9]\+]' | sed 's/\(\[\|]\)//g'`

        #Remove only first occurence of '. ' if present in beg
        sed -i -e '0,/\. / s///' inter.txt
        sed -i 's/\. //g' inter.txt

        # Remove cites from first line of main text
        sed -i $len,$len's/\[[0-9]\+]//g' inter.txt

        # Append ~ around numbers around nth line and create a result file
        ptext=`cat inter.txt | sed "${len}q;d"`
        ptext="~ $cite ~ $ptext"

        echo $ptext >> lines.txt
        ((len++))
    done

    while true
    do

        # Take queries
        echo "Chose type of query"
        echo "[1]: Get lines with citation X"
        echo "[2]: Get citations of a line"

        read choice

        case "$choice" in
            #   For queries of type 1
            1)  echo "Enter citation number: "
                read inp

                # Use cite shell variable in regex to search from result set
                res=`cat lines.txt | grep ".* $inp .*"`

                # Remove all citation numbers from result
                res=`echo $res | sed 's/~.\+~//g'`

                # Print output
                echo $res
                ;;

            #   For queries of type 2
            2)  echo "Enter string: "
                read str

                # select searched line from result file
                res=`cat lines.txt | grep -o "$str"`

                # remove text and keep citation numbers
                res=`echo $res | grep -o '~.~'`

                # Print output
                echo $res
                ;;

            #   Default case
            *)  echo "Invalid Input"
                echo "The program will now exit..."
                ;;

        esac

        read "Do you wish to continue? (y/n)" wish
        echo $wish

        if [ "$wish" == "y" ]; then
            break
        fi
    done

# done < "$filename"





