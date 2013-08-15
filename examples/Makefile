all:
	dmd -I../source ../libgumbo-d.a `pkg-config --variable=libdir  gumbo`/libgumbo.a find_links.d
	dmd -I../source ../libgumbo-d.a `pkg-config --variable=libdir  gumbo`/libgumbo.a find_links_new.d

clean:
	rm -f *.o find_links find_links_new
