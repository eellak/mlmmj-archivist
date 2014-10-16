#!/bin/sh
#
# mlmmj-archivist: create web archives for mlmmj
#
# Copyright (c) 2013 Manolis Tzanidakis <mtzanidakis@gmail.com>
#
# Permission to use, copy, modify, and distribute this software for any
# purpose with or without fee is hereby granted, provided that the above
# copyright notice and this permission notice appear in all copies.
#
# THE SOFTWARE IS PROVIDED "AS IS" AND THE AUTHOR DISCLAIMS ALL
# WARRANTIES WITH REGARD TO THIS SOFTWARE INCLUDING ALL IMPLIED
# WARRANTIES OF MERCHANTABILITY AND FITNESS. IN NO EVENT SHALL THE
# AUTHOR BE LIABLE FOR ANY SPECIAL, DIRECT, INDIRECT, OR CONSEQUENTIAL
# DAMAGES OR ANY DAMAGES WHATSOEVER RESULTING FROM LOSS OF USE, DATA OR
# PROFITS, WHETHER IN AN ACTION OF CONTRACT, NEGLIGENCE OR OTHER
# TORTIOUS ACTION, ARISING OUT OF OR IN CONNECTION WITH THE USE OR
# PERFORMANCE OF THIS SOFTWARE.


# error message
_error() {
	echo "error: ${@}."
	exit 1
}

# use seq or jot or fail if none is available
if which seq >/dev/null 2>&1; then
	_seq="$(which seq)"
elif which jot >/dev/null 2>&1; then
	_seq="$(which jot) -"
else
	_error "no seq or jot installed"
fi

# check if requirements are installed
for _cmd in awk file mhonarc; do
	which ${_cmd} >/dev/null 2>&1 || \
		_error "${_cmd} is not installed"
done

# convert the message's post date to something usable
# usage: _datefmt [date string]
# returns a string with the date in the fmt of YYYY/MM
_datefmt() {
	# the formatted date string to work on
	_datestr="$1"

	# convert month name to number
	case "$(echo ${_datestr} | awk '{ print $3 }')" in
		Jan) _month=01 ;;
		Feb) _month=02 ;;
		Mar) _month=03 ;;
		Apr) _month=04 ;;
		May) _month=05 ;;
		Jun) _month=06 ;;
		Jul) _month=07 ;;
		Aug) _month=08 ;;
		Sep) _month=09 ;;
		Oct) _month=10 ;;
		Nov) _month=11 ;;
		Dec) _month=12 ;;
	esac

	# get the year
	_year="$(echo ${_datestr} | awk '{ print $4 }')"

	# 'return' the complete string
	echo "${_year}/${_month}"
}

# the default configuration file
# XXX: switch to the actual configuration file after Makefile
# is available
_conffile="./mlmmj-archivist.conf.sample"

# parse the configuration file
if [ -s ${_conffile} ]; then
	# get the mlmmj spool path
	_mlmmj_spool=$(awk -F '=' \
		'/_mlmmj_spool/ {gsub("\"", ""); gsub("'\''", ""); print $2}' \
		${_conffile})

	# get the public html path
	_public_html=$(awk -F '=' \
		'/_public_html/ {gsub("\"", ""); gsub("'\''", ""); print $2}' \
		${_conffile})

	# get the public url
	_public_url=$(awk -F '=' \
		'/_public_url/ {gsub("\"", ""); gsub("'\''", ""); print $2}' \
		${_conffile})
else
	_error "configuration file not found"
fi

# loop over the mailing lists that contain the dir archivist
for _workpath in $(find ${_mlmmj_spool} -type d -name 'archivist')
do
	# clear vars to avoid confusion
	unset _curindex _lastindex

	# the list spool path
	_listpath="${_workpath%%/archivist}"

	# check the index file and skip empty lists
	test -s "${_listpath}/index" \
		&& _curindex="$(cat ${_listpath}/index)" \
		|| continue

	# read the last index, or set it to 1 if not available
	test -s "${_workpath}/lastindex" \
		&& _lastindex="$(cat ${_workpath}/lastindex)" \
		|| _lastindex=1

	# skip lists that are up to date
	if [ "${_lastindex}" -ne 1 ] && [ ${_curindex} -le ${_lastindex} ]; then
		continue
	fi

	# list short name. use cut to get only the listname when
	# domain/listname structure is used
	_shortname=$(echo ${_listpath##${_mlmmj_spool}/} | cut -d '/' -f2)
	# create the output directory if not available
	test -d "${_public_html}" || install -d -m 0755 "${_public_html}"

	# create list output directory if not available
	_listout="${_public_html}/${_shortname}"

	test -d "${_listout}" || install -d -m 0755 "${_listout}"

	# parse messages to create the list archive
	for _msg in $(${_seq} ${_lastindex} ${_curindex}); do
		# the message file
		_msgfile="${_listpath}/archive/${_msg}"

		# skip unavailable messages
		test -s "${_msgfile}" || continue

		# get the message date and convert it to the message month
		_msgdate="$(awk \
			'/Date: / { print substr($0, index($0, $2))}' \
			${_msgfile})"
		_msgmonth=$(_datefmt "${_msgdate}")

		# create month directory if not available
		test -d "${_listout}/${_msgmonth}" \
			|| install -d -m 0755 "${_listout}/${_msgmonth}"

		# XXX: replace with actual mhonarc command
		# XXX: remove last 4 lines - the list signature
		mhonarc -rcfile ./mhonarc/mhonarc.mrc \
			-outdir "${_listout}/${_msgmonth}" \
			-lang "el" \
			-subjectstripcode "s/\[${_shortname}\]//;" \
			-title "${_shortname}" \
			-add < "${_msgfile}"

		# XXX separate attachments (paths/urls)

		# update last index counter on success
		[ "$?" -eq 0 ] && echo ${_msg} > ${_workpath}/lastindex
	done

	## XXX: create the main archive page
	## XXX: replace manual creation with a proper 'template' file

	# temporary main index
	if _temp_mainindex="$(mktemp ${_workpath}/index.html.XXXXXX)"; then
		trap 'rm -f ${_temp_mainindex}; exit 1' 0 1 15
	else
		_error "temp file creation failed"
	fi

	echo "<!DOCTYPE html>\n<html><head><title>${_shortname}</title></head><body>" >> ${_temp_mainindex}

	for _year in $(find ${_listout} -mindepth 1 -maxdepth 1 -type d); do
		echo "<h2>${_year##${_listout}/}</h2>" >> ${_temp_mainindex}

		echo '<ul>' >> ${_temp_mainindex}

		for _month in $(find ${_year} -mindepth 1 -maxdepth 1 -type d | sort -r)
		do
			_link=$(echo ${_month} | sed -e "s@${_public_html}@${_public_url}@g")

			echo "<li><a href="${_link}">${_month##${_year}/}</a></li>" >> \
				${_temp_mainindex}
		done

		echo '</ul>' >> ${_temp_mainindex}
	done

	echo '</body></html>' >> ${_temp_mainindex}

	# move temp main index to the list archive's index.html
	mv ${_temp_mainindex} ${_listout}/index.html
	chmod 0644 ${_listout}/index.html
done
