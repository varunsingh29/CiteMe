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

    # Get source code using curl
    # regex to scrap off html code
    curl $url | sed 's/<\/*[^>]*>//g' > scraped.txt

    # put citations before full stop in sentences - silly hack
    sed -i 's/\.\(\[[0-9]\+]\)\+/&&\./g' scraped.txt
    sed -i 's/\.\(\[[0-9]\+]\)\+\.//g' scraped.txt

    # remove all empty lines
    sed -i '/^$/d' scraped.txt

    # Find patterns/
    grep -o '\(\. \)\?\([^\.]\|[0-9]*\.[0-9]\+\)*\(\[[0-9]\+]\)\+[^\.]*' scraped.txt > inter.txt

    # While citations are present, proceed
    while grep -q '\[[0-9]\+]' inter.txt
    do
        # select top most line with citations using head
        str=`grep -o '\(\. \)\?\([^\.]\|[0-9]*\.[0-9]\+\)*\(\[[0-9]\+]\)\+[^\.]*' inter.txt | head -1`

        # Store all citation numbers in a var after removing []
        cite=`echo $str | grep -o '\[[0-9]\+]' | sed 's/\(\[\|]\)//g'`

        # Remove '. ' from only first line if present
        # Important to do line by line regex used \.
        sed -i 1,1's/\. //g' inter.txt

        # Remove cites from first line of main text
        sed -i 1,1's/\[[0-9]\+]//g' inter.txt

        # Select first line i.e being processed
        ptext=`cat inter.txt | head -1`

        # Preprocess $ptext to escape \ in variable
        ptext=$(echo "$ptext" | sed 's/\//\\\//g')

        # Preprocess $ptext to escape [] in variable.
        # Use capture groups to process [text] except citations
        ptext=$(echo "$ptext" | sed 's/\[\([^0-9].\+[^0-9]\)\]/\\\[\1\\\]/g')

        # Delete processed line bc $str uses first line
        sed -i "/$ptext/d" inter.txt

        # Format the output with ~ and put results in a file
        ptext="~ $cite ~ $ptext"
        echo $ptext >> lines.txt
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
                # Using files because keeps line endings intact
                cat lines.txt | grep "~.* $inp .*~" > final.txt

                # Remove all citation numbers from result
                sed -i 's/~.\+~//g' final.txt

                # Print output
                echo "String(s): "
                cat final.txt
                ;;

            #   For queries of type 2
            2)  echo "Enter string: "
                read str

                # Remove Full stop from end if present. If not, grep wont match
                str=`echo $str | sed 's/\.$//g'`

                # select searched line from result file
                res=`cat lines.txt | grep "$str"`

                # remove text and keep citation numbers
                res=`echo $res | grep -o '~.\+~' | sed 's/~//g'`

                # Print output
                echo "Citation(s): " $res
                ;;

            #   Default case
            *)  echo "Invalid Input"
                echo "The program will now exit..."
                break
                ;;

        esac

        echo "Do you wish to continue? (y/n)"
        read wish

        if [ "$wish" == "n" ] ; then
            break
        fi
    done

    # Cleaning up directory
    rm -f final.txt inter.txt lines.txt
# done < "$filename"





