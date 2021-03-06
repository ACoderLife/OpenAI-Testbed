.PHONY: up-nix up-win down clean

# -----------------------------------------------------------------------------
#  CONSTANTS
# -----------------------------------------------------------------------------

container_dir  = container
build_dir      = build
train_dir      = train
util_dir       = util

depend_log     = $(build_dir)/.depend

container_tag  = openai/smb
container_name = openai_smb

# -----------------------------------------------------------------------------
#  FUNCTIONS
# -----------------------------------------------------------------------------

up-nix: down
	docker run \
		--name $(container_name) \
		-e VNC_SERVER_PASSWORD=password \
		-p 5900:5900 \
		-p 8000:8000 \
		-v $(shell pwd)/$(train_dir):/opt/$(train_dir) \
		-v $(shell pwd)/$(util_dir):/opt/$(util_dir) \
		-d $(container_tag)

up-win: down
	docker run \
		--name $(container_name) \
		-e VNC_SERVER_PASSWORD=password \
		-p 5900:5900 \
		-p 8000:8000 \
		-v /c/workspace/OpenAI-Testbed/$(train_dir):/opt/$(train_dir) \
		-v /c/workspace/OpenAI-Testbed/$(util_dir):/opt/$(util_dir) \
		-d $(container_tag)

down:
	bash -c "trap 'docker rm -f $(container_name)' EXIT"

# -----------------------------------------------------------------------------
#  CLEANUP
# -----------------------------------------------------------------------------

clean:
	rm -rf $(build_dir)

# -----------------------------------------------------------------------------
#  DEPENDENCIES
# -----------------------------------------------------------------------------

depend: $(depend_log)

$(depend_log): $(shell find $(container_dir) -maxdepth 5 -name "*")
	rm -f $(depend_log)
	mkdir -p $(build_dir)

	docker build ./$(container_dir) --tag $(container_tag)

	@echo Updated at: `/bin/date "+%Y-%m-%d---%H-%M-%S"` >> $(depend_log);

include $(depend_log)
