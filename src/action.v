module main

import os
import cli
import flag

// Create flags

struct Action {
    opts &ActionOptions
    res string
    cwd string
}

struct ActionOptions {
    is_verbose bool
    is_interactive bool // NB: Not implemented
    path_to_script_dir string
    args []string
    script string
    script_args string
    rest []string
}

const (
	/*
	* flag: bool, int, float, int_array, float_array, string_array
	* name
	* abbrev
	* description
	* global
	* default_value
	**/
	path_to_scripts = cli.Flag{
		flag: cli.FlagType.string
		name: 'path'
		abbrev: 'p'
		description: 'Path to script directory'
		required: false
	}
	verbose = cli.Flag{
		flag: cli.FlagType.bool
		name: 'verbose'
		abbrev: 'v'
		description: 'Add some verbosity to this thing'
		required: false
	}
	interactive = cli.Flag{
		flag: cli.FlagType.bool
		name: 'interactive'
		abbrev: 'i'
		description: 'Run in interactive mode'
		required: false
	}
)

fn find_scripts_dir(path string, scripts_dir string) ?string {
	if path == '/' {
		return error('$scripts_dir not found in directory path. Try supplying a direct path')
	}
	// println('Checking $path for $scripts_dir')
	script_path := '$path/$scripts_dir'
	if os.exists(script_path) {
		return script_path
	}

	return find_scripts_dir(os.dir(path), scripts_dir)
}

fn list_scripts(path string) {
	files := os.ls(path) or {
		eprintln('No available scripts in $path')
		exit(1)
	}
	println(files)
}

fn find_script(path string, script string) ?string {
    // checks: file exists, is executable
    println('files: ')
    mut dirs := []string{}
    mut files := os.ls(path)?
    for file in files {
        f := '$path/$file'
        println(file)
        if os.is_dir(f) {
            dirs << f
            continue
        }
        if os.is_file(f) && file == script {
            if os.is_executable(file) {
                return f
            } else {
                return error('$f is not executable')
            }
        }
    }
    if dirs.len == 0 {
        return error('Unable to find $script')
    }
    return find_script(dirs.pop(), script)
}

fn execute_script(path string, script string, args []string) {
	os.execvp('$path/$script', args) or {
		eprintln(err)
		exit(1)
	}
}

fn parse_options(mut fp flag.FlagParser) ?&ActionOptions{
    return &ActionOptions{
    is_verbose: fp.bool('verbose', `v`, false, 'Show verbose output')
    is_interactive: fp.bool('interactive', `i`, false, 'Run interactive script picker')
    path_to_script_dir: fp.string('path', `p`, '', 'Use this path to look for the SCRIPTS directory')
    script: if fp.args.len > 0 { fp.args[0] } else { '' }
    // script_args: fp.remaining_parameters()?[1..]
    rest: fp.finalize() or { [] }
    }
}


fn main() {
	cwd := os.dir(os.args[0])
    mut fp := flag.new_flag_parser(os.args)
    fp.application(os.file_name(os.executable()))
    fp.description("a cool tool")
    fp.arguments_description("[SCRIPT [...ARGS]")
    fp.skip_executable()

    println("FlagParser: $fp")
    mut a := &Action{
        opts: parse_options(mut fp) or {
            eprintln(err)
            exit(1)
        }
    }
    println("Action: $a")
    if os.args.len < 2 {
        eprintln(fp.usage())
        exit(1)
    }

    println("path_to_script_dir: ${a.opts.path_to_script_dir}")
    println("script: ${a.opts.script}")
    println("rest: ${a.opts.rest}")

    // TODO: There has got to be a better way to do this, but that's a
    // problem for tomorrow
	mut scripts_path := ''
	scripts_path = a.opts.path_to_script_dir
	if scripts_path == '' {
		scripts_path = find_scripts_dir(cwd, 'scripts') or {
			eprintln(err)
			exit(1)
		}
	}

    /* If we reach this point, we should have a path to a script
     * directory. If a specific script has been provided, call it,
     * otherwise list the scripts in the directory
     */
	println(scripts_path)
    if a.opts.script != '' {
        // walk scripts dir to find script
        full_path_to_script_exe := find_script(scripts_path, a.opts.script) or {
            eprintln(err)
            exit(1)
        }
        //execute_script(full_path_to_script_exe, a.opts.script, a.opts.script_args)
        println(full_path_to_script_exe)
    } else {
        list_scripts(scripts_path)
    }
}
