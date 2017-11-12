DUB_BUILD := dub build

all: bin/aisndjson_to_aismmfile  \
     bin/aismmfile_ls  \
     bin/aismmfile_cat

bin/aisndjson_to_aismmfile: app_src/aisndjson_to_aismmfile.d source/aismmfile/*.d
	$(DUB_BUILD) --config=aisndjson_to_aismmfile

bin/aismmfile_ls: app_src/aismmfile_ls.d source/aismmfile/*.d
	$(DUB_BUILD) --config=aismmfile_ls

bin/aismmfile_cat: app_src/aismmfile_cat.d source/aismmfile/*.d
	$(DUB_BUILD) --config=aismmfile_cat

.PHONY: test
test:
	dub test

.PHONY: clean
clean:
	dub clean
	rm -f bin/aisndjson_to_aismmfile  \
	      bin/aismmfile_ls  \
	      bin/aismmfile_cat

## TODO add install rule for programs
