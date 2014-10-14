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

	#} get the year
	_year="$(echo ${_datestr} | awk '{ print $4 }')"

	# 'return' the complete string
	echo "${_year}/${_month}"
}

# the default configuration file
# XXX: switch to the actual configuration file after Makefile
# is available
_conffile="./mlmmj-archivist.conf.sample"

# load the configuration file
test -s ${_conffile} \
	&& . ${_conffile} \
	|| _error "configuration file not found"

# get a list or mailing lists to process
# (aka the ones that contain archivist in control dir)
for _listpath in \
	$(find ${_mlmmj_spool} -type f -name 'archivist' | \
		sed -e 's:/control/archivist::g')
do
	# clear vars to avoid confusion
	unset _curindex _lastindex

	# check the index file and skip empty lists
	test -s "${_listpath}/index" \
		&& _curindex="$(cat ${_listpath}/index)" \
		|| continue

	# the archivist directory where we store mlmmj-archivist
	# related files
	_workpath="${_listpath}/archivist"

	# create the archivist directory if not available
	test -d "${_workpath}" || install -d -m 0755 "${_workpath}"

	# read the last index
	test -s "${_workpath}/lastindex" \
		&& _lastindex="$(cat ${_workpath}/lastindex)"

	# skip lists that are up to date
	if [ "${_lastindex}" ] && [ ${_curindex} -le ${_lastindex} ]; then
		continue
	fi

	# list short name. use cut to get only the listname when
	# domain/listname structure is used
	_shortname=$(echo ${_listpath} | sed -e "s:${_mlmmj_spool}/::g" | \
		cut -d '/' -f 2)

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
		mhonarc -idxfname index.html \
			-outdir "${_listout}/${_msgmonth}" \
			-lang "el" -spammode \
			-addressmodifycode 's/@/ [ at ] /; s/\./ [ dot ] /g;' \
			-modifybodyaddresses \
			-title "${_shortname}" \
			-add < "${_msgfile}"

		# XXX separate attachments (paths/urls)
	done
done
