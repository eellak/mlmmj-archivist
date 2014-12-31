#!/bin/sh
#
# mlmmj-archivist: create web archives for mlmmj
#
# Copyright (c) 2014 Manolis Tzanidakis <mtzanidakis@gmail.com>
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

# check if requirements are installed
for _cmd in awk file mhonarc rsync; do
	which ${_cmd} >/dev/null 2>&1 || \
		_error "${_cmd} is not installed"
done

# convert the message's post date to something usable
# usage: _datefmt [date string]
# 'returns' a string with the date in the fmt of YYYY/MM
_datefmt() {
	# the formatted date string to work on
	_datestr="$1"

	# get the year
	_yearfmt="$(echo ${_datestr} | awk '{ print $6 }')"

	# convert month name to number
	case "$(echo ${_datestr} | awk '{ print $2 }')" in
		Jan) _monthfmt=01 ;;
		Feb) _monthfmt=02 ;;
		Mar) _monthfmt=03 ;;
		Apr) _monthfmt=04 ;;
		May) _monthfmt=05 ;;
		Jun) _monthfmt=06 ;;
		Jul) _monthfmt=07 ;;
		Aug) _monthfmt=08 ;;
		Sep) _monthfmt=09 ;;
		Oct) _monthfmt=10 ;;
		Nov) _monthfmt=11 ;;
		Dec) _monthfmt=12 ;;
	esac
	# 'return' the complete string
	echo "${_yearfmt}/${_monthfmt}"
}

# reverse previous function to create the date for mhonarc
# templates
# usage: _datefmtrev YYYY/mm
# 'returns' a string with the date in the fmt of Month( YYYY)
_datefmtrev() {
	# the formatted date string to work on
	_datestr="$1"

	if echo ${_datestr} | grep -q '/'; then
		# get the year
		_yearfmt=$(echo ${_datestr} | cut -d '/' -f 1)

		# get the month number
		_monthfmt="$(echo ${_datestr} | cut -d '/' -f 2)"
	else
		_monthfmt="${_datestr}"
	fi

	# convert month number to name
	case "${_monthfmt}" in
		01) _monthfmt="${_str_mon_jan:-January}" ;;
		02) _monthfmt="${_str_mon_feb:-February}" ;;
		03) _monthfmt="${_str_mon_mar:-March}" ;;
		04) _monthfmt="${_str_mon_apr:-April}" ;;
		05) _monthfmt="${_str_mon_may:-May}" ;;
		06) _monthfmt="${_str_mon_jun:-June}" ;;
		07) _monthfmt="${_str_mon_jul:-July}" ;;
		08) _monthfmt="${_str_mon_aug:-August}" ;;
		09) _monthfmt="${_str_mon_sep:-September}" ;;
		10) _monthfmt="${_str_mon_oct:-October}" ;;
		11) _monthfmt="${_str_mon_nov:-November}" ;;
		12) _monthfmt="${_str_mon_dec:-December}" ;;
	esac

	if [ "${_yearfmt}" ]; then
		echo "${_monthfmt} ${_yearfmt}"
	else
		echo "${_monthfmt}"
	fi
}

# the default configuration file
_conffile="__SYSCONFDIR__/mlmmj-archivist.conf"

# source the configuration file
[ -s ${_conffile} ]       \
	&& . ${_conffile} \
	|| _error "configuration file not found"

# initialize mhonarc command arguments variable
# set default language to english
_mhonarc_args="-lang en_US -definevar HTML-LANG='en'"

# the <html> language
_html_lang="$(echo ${_language} | cut -d '_' -f 1)"

# set language
if [ ${_language} != 'en_US' ]; then
	_mhonarc_args="-lang ${_language} -definevar HTML-LANG='${_html_lang}'"

	# check if localized version of the selected template exists
	# and use that, or fallback to english
	test -d "__SHAREDIR__/templates/${_template}.${_html_lang}" &&
		_template="${_template}.${_html_lang}" \

	# check if translated strings are available and source it
	test -s "__SHAREDIR__/templates/${_template}/trans_str.txt" &&
		. "__SHAREDIR__/templates/${_template}/trans_str.txt"
fi

# set the template
_mhontemplate="__SHAREDIR__/templates/${_template}/mhonarc/template.mrc"
[ -s "${_mhontemplate}" ] \
	&& _mhonarc_args="${_mhonarc_args} \
		-definevar TEMPLATE-NAME='${_template}' \
		-rcfile ${_mhontemplate}" \
	|| _error "the selected template is not available"

# loop over the mailing lists that contain the dir archivist
for _workpath in $(find ${_mlmmj_spool} -maxdepth 3 -type d -name 'archivist')
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
	_msg=${_lastindex}

	while [ ${_msg} -le ${_curindex} ]; do
		# the message file
		_msgfile="${_listpath}/archive/${_msg}"

		# skip unavailable messages
		if [ ! -s "${_msgfile}" ]; then
			# increment the counter first
			_msg=$((${_msg} + 1))

			continue
		fi

		# get the message date and convert it to something parsable to
		# avoid problems from misconfigured smtp servers (looking at
		# you, qmail) -- requires gnu date unfortunately.
		# XXX: find posix-compliant alternative solution.
		_msgdate=$(date --date="$(awk \
			'/^Date: / { print substr($0, index($0, $2)); exit }' \
			${_msgfile})")

		# convert the date to the message month
		_msgmonth=$(_datefmt "${_msgdate}")

		# create month directory if not available
		test -d "${_listout}/${_msgmonth}" \
			|| install -d -m 0755 "${_listout}/${_msgmonth}"

		# create the web archives
		mhonarc -rcfile __SYSCONFDIR__/mhonarc.mrc ${_mhonarc_args}  \
			-definevar DATE-FMT="'$(_datefmtrev ${_msgmonth})'"  \
			-definevar LIST-NAME="'${_shortname}'"               \
			-definevar PUBLIC-URL="'${_public_url}'"             \
			-definevar LIST-URL="'${_public_url}/${_shortname}'" \
			-outdir "${_listout}/${_msgmonth}"                   \
			-subjectstripcode "s/\[${_shortname}\]//;"           \
			-quiet -add < "${_msgfile}"

		# update last index counter on success
		[ "$?" -eq 0 ] && echo ${_msg} > ${_workpath}/lastindex

		# increment the counter
		_msg=$((${_msg} + 1))
	done

	# create the assets directory if not available, first,
	# to have the rsync --delete option work correctly
	test -d ${_public_html}/assets || \
		install -d -m 0755 ${_public_html}/assets

	# synchronize assets from template
	rsync -aq --delete --delete-after                   \
		__SHAREDIR__/templates/${_template}/assets/ \
		${_public_html}/assets/

	## create list information page

	# temporary listinfo page
	if _temp_listinfo="$(mktemp ${_workpath}/listinfo.html.XXXXXX)"; then
		trap 'rm -f ${_temp_listinfo}; exit 1' 0 1 15
	else
		_error "temp file creation failed"
	fi

	# if the list contains long description append it to the page content
	test -s ${_workpath}/longdesc && \
		_content="${_content} $(tr '\n' ' ' < ${_workpath}/longdesc)"

	# get the list addresses
	# use sed because debian default sh (dash) does not support
	# string substitution in vars
	_addrlist="$(cat ${_listpath}/control/listaddress)"
	_addrsub=$(echo ${_addrlist} |
		sed -e "s:${_shortname}:${_shortname}+subscribe:")
	_addrsubdig=$(echo ${_addrlist} |
		sed -e "s:${_shortname}:${_shortname}+subscribe-digest:")
	_addrsubnomail=$(echo ${_addrlist} |
		sed -e "s:${_shortname}:${_shortname}+subscribe-nomail:")
	_addrunsub=$(echo ${_addrlist} |
		sed -e "s:${_shortname}:${_shortname}+unsubscribe:")
	_addrhelp=$(echo ${_addrlist} |
		sed -e "s:${_shortname}:${_shortname}+help:")
	_addrfaq=$(echo ${_addrlist} |
		sed -e "s:${_shortname}:${_shortname}+faq:")
	_addrowner="$(cat ${_listpath}/control/owner)"

	# handle closed subscriptions
	if      [ -e ${_listpath}/control/closedlist    ] ||
		[ -e ${_listpath}/control/closedlistsub ]
	then
		_sedsub1="s@\[OPENLIST\].*\[OPENLIST\]@@g"
		_sedsub2="s@\[CLOSEDLIST\]@@g"
	else
		_sedsub1="s@\[CLOSEDLIST\].*\[CLOSEDLIST\]@@g"
		_sedsub2="s@\[OPENLIST\]@@g"
	fi

	# handle digest subscriptions
	test -e ${_listpath}/control/nodigestsub           \
		&& _sedsubdig="s@\[SUBDIG\].*\[SUBDIG\]@@" \
		|| _sedsubdig="s@\[SUBDIG\]@@g"

	# handle nomail subscriptions
	test -e ${_listpath}/control/nonomailsub                    \
		&& _sedsubnomail="s@\[SUBNOMAIL\].*\[SUBNOMAIL\]@@" \
		|| _sedsubnomail="s@\[SUBNOMAIL\]@@g"

	# get the correct mailing list addresses
	sed     -e "s@__HTMLLANG__@${_html_lang}@g"               \
		-e "s@__LISTNAME__@${_shortname}@g"               \
		-e "s@__PUBURL__@${_public_url}@g"                \
		-e "s@__CONTENT__@${_content}@g"                  \
		-e "s#__ADDRLIST__#${_addrlist}#g"                \
		-e "s#__ADDRSUB__#${_addrsub}#g"                  \
		-e "s#__ADDRSUBDIG__#${_addrsubdig}#g"            \
		-e "s#__ADDRSUBNOMAIL__#${_addrsubnomail}#g"      \
		-e "s#__ADDRUNSUB__#${_addrunsub}#g"              \
		-e "s#__ADDRHELP__#${_addrhelp}#g"                \
		-e "s#__ADDRFAQ__#${_addrfaq}#g"                  \
		-e "s#__ADDROWNER__#${_addrowner}#g"              \
		-e "${_sedsub1}" -e "${_sedsub2}"                 \
		-e "${_sedsubdig}" -e "${_sedsubnomail}"          \
		__SHAREDIR__/templates/${_template}/listinfo.tmpl \
		> ${_temp_listinfo}

	mv ${_temp_listinfo} ${_listout}/listinfo.html
	chmod 0644 ${_listout}/listinfo.html

	unset _content

	## create list archive index page

	# temporary main index
	if _temp_mainindex="$(mktemp ${_workpath}/index.html.XXXXXX)"; then
		trap 'rm -f ${_temp_mainindex}; exit 1' 0 1 15
	else
		_error "temp file creation failed"
	fi

	# create the list of months/years
	for _year in $(find ${_listout} -mindepth 1 -maxdepth 1 -type d | sort -r)
	do
		_content="${_content}<div class=\"month-list\">\n"
		_content="${_content}\t\t\t<h2>${_year##${_listout}/}</h2>\n\n"
		_content="${_content}\t\t\t<table>\n\t\t\t\t<tbody>\n"

		for _month in $(find ${_year} -mindepth 1 -maxdepth 1 -type d |
			sort -r)
		do
			# get the month formatted
			_monthnr="${_month##${_year}/}"

			_monthfmt="$(_datefmtrev ${_monthnr})"

			# the month url
			_monthurl=$(echo ${_month} | \
				sed -e "s@${_public_html}@${_public_url}@g")

			# date and thread index links
			_monthindex="<a href=\"${_monthurl}\">${_str_dat_idx:-date index}</a>"
			_monthtindex="<a href=\"${_monthurl}/tindex.html\">${_str_thr_idx:-thread index}</a>"

			_content="${_content}\t\t\t\t\t<tr>\n"
			_content="${_content}\t\t\t\t\t\t<th>${_monthfmt}</th>\n"
			_content="${_content}\t\t\t\t\t\t<td>${_monthindex}</td>\n"
			_content="${_content}\t\t\t\t\t\t<td>${_monthtindex}</td>\n"
			_content="${_content}\t\t\t\t\t</tr>\n"
		done

		_content="${_content}\t\t\t\t</tbody>\n\t\t\t</table>"
		_content="${_content}\n\t\t</div><!-- .month-list -->"
	done

	# write content in the temp file to avoid race conditions
	sed     -e "s@__HTMLLANG__@${_html_lang}@g"               \
		-e "s@__LISTNAME__@${_shortname}@g"               \
		-e "s@__PUBURL__@${_public_url}@g"                \
		-e "s@__CONTENT__@${_content}@g"                  \
		__SHAREDIR__/templates/${_template}/listpage.tmpl \
		> ${_temp_mainindex}

	# move temp main index to the list archive's index.html
	mv ${_temp_mainindex} ${_listout}/index.html
	chmod 0644 ${_listout}/index.html

	unset _content
done

# create the homepage
if _mlists=$(find ${_public_html} -mindepth 1 -maxdepth 1 -type d \
	-not -name 'assets' -exec basename {} \; | sort) 2>/dev/null
then
	# temporary homepage index
	if _temp_homeindex="$(mktemp ${_public_html}/.index.html.XXXXXX)"; then
		trap 'rm -f ${_temp_homeindex}; exit 1' 0 1 15
	else
		_error "temp file creation failed"
	fi

	# create links to available lists, alphabetically sorted
	for _mlist in $(echo ${_mlists}); do
		_workpath="$(find ${_mlmmj_spool} -maxdepth 3 -type d \
			-name ${_mlist})/archivist"

		# skip adding the list to the home page if configured so
		test -e ${_workpath}/homeless && continue

		_mlisturl="<h3 class=\"listname\"><a href=\"${_public_url}/${_mlist}/listinfo.html\">${_mlist}</a></h3>"
		_content="${_content}${_mlisturl}"

		# if the list contains short description append it to
		# the page content
		test -s ${_workpath}/shortdesc && \
			_content="${_content} <p>$(cat ${_workpath}/shortdesc)</p>"
	done

	# output homepage to the temp file
	sed     -e "s@__HTMLLANG__@${_html_lang}@g"               \
		-e "s@__PUBURL__@${_public_url}@g"                \
		-e "s@__CONTENT__@${_content}@g"                  \
		__SHAREDIR__/templates/${_template}/homepage.tmpl \
		> ${_temp_homeindex}

	mv ${_temp_homeindex} ${_public_html}/index.html
	chmod 0644 ${_public_html}/index.html

	unset _content
fi
