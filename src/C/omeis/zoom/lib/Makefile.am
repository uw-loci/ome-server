noinst_LIBRARIES = libpic.a libzoom.a
libzoom_a_SOURCES = zoom.c scanline.c filt.c ../include/zoom.h \
					../include/scanline.h ../include/filt.h \
					../include/simple.h
libpic_a_SOURCES = window.c pic.c pic_file.c pic_all.c swap.c tiff.c jpeg.c \
				   png.c omeis.c ../include/window.h ../include/pic.h \
				   ../include/simple.h ../include/pixel.h
AM_CPPFLAGS = -DOMEIS_ROOT=\"$(OMEIS_ROOT)\" -DOMEBF_BIN=\"$(OMEBF_BIN)\" -I../include @LIBXML2_CFLAGS@
