/* Copyright (c) 2018 Paul McMath <paulm@tetrardus.net>
 *
 * Permission to use, copy, modify, and distribute this software for any
 * purpose with or without fee is hereby granted, provided that the above
 * copyright notice and this permission notice appear in all copies.
 *
 * THE SOFTWARE IS PROVIDED "AS IS" AND THE AUTHOR DISCLAIMS ALL WARRANTIES
 * WITH REGARD TO THIS SOFTWARE INCLUDING ALL IMPLIED WARRANTIES OF
 * MERCHANTABILITY AND FITNESS. IN NO EVENT SHALL THE AUTHOR BE LIABLE FOR
 * ANY SPECIAL, DIRECT, INDIRECT, OR CONSEQUENTIAL DAMAGES OR ANY DAMAGES
 * WHATSOEVER RESULTING FROM LOSS OF USE, DATA OR PROFITS, WHETHER IN AN
 * ACTION OF CONTRACT, NEGLIGENCE OR OTHER TORTIOUS ACTION, ARISING OUT OF
 * OR IN CONNECTION WITH THE USE OR PERFORMANCE OF THIS SOFTWARE.
 */
#define PERL_NO_GET_CONTEXT
#include "EXTERN.h"
#include "perl.h"
#include "XSUB.h"

#include "ppport.h"

#include <stdlib.h>
#include <unistd.h>
#include <stdio.h>
#include <string.h>
#include <X11/Xlib.h>
#include <X11/Xatom.h>

char *get_wmname(void);

MODULE = GetSystemData		PACKAGE = GetSystemData		
PROTOTYPES: DISABLE

char *
get_wmname()
	PREINIT:
	Display *disp;
	Window *win;
	char *wm_name;
	char *name;
	unsigned long ret_nitems;
	unsigned long ret_bytes_after;
	unsigned long len;
	unsigned char *prop_1, *prop_2;
	Atom propname;
	Atom ret_type;
	int ret_format;

	CODE:
	win = NULL;
	wm_name = NULL;

	if ((disp = XOpenDisplay(NULL))) {
	    propname = XInternAtom(disp, "_NET_SUPPORTING_WM_CHECK", False);
	    if (XGetWindowProperty(disp, DefaultRootWindow(disp), propname, \
		0, 1024, False, XA_WINDOW, &ret_type, &ret_format, &ret_nitems, \
		&ret_bytes_after, &prop_1) == Success && (ret_type != XA_WINDOW)) {

		len = (ret_format / 8) * ret_nitems;
		if ((name = malloc((ret_format / 8 * ret_nitems) + 1)) != NULL) {
		    memcpy(name, prop_1, len);
		    name[len] = '\0';    
		    win = (Window *)name;

		    propname = XInternAtom(disp, "_NET_WM_NAME", False);
		    if (XGetWindowProperty(disp, *win, propname, 0, 1024, False, \
			XInternAtom(disp, "UTF8_STRING", False), &ret_type, &ret_format, \
			&ret_nitems, &ret_bytes_after, &prop_2) == Success) {

			len = (ret_format / 8) * ret_nitems;
			if ((wm_name = malloc(len + 1)) != NULL) {
			    memcpy(wm_name, prop_2, len);
			    wm_name[len] = '\0';
			}
			XFree(prop_2);
		    }
		    free(name);
		}
		XFree(prop_1);
	    }
	    XCloseDisplay(disp);
	}
	RETVAL = wm_name;
	OUTPUT:
	    RETVAL

