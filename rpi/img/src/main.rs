extern crate rustc_serialize;
extern crate docopt;
extern crate glob;

use docopt::Docopt;
use std::io::Write;
use std::path::PathBuf;
use glob::glob;

#[cfg_attr(rustfmt, rustfmt_skip)]
const USAGE: &'static str = "
Kibar imager. Helper utils to download, format, install and manage raspbery
pi images for the kibar project.

Usage:
  img install <device>
  img mount <device> <location>
  img unmount (<device> | <location>)
  img chroot <device>
  img (-h | --help | --version)

Options:
  -h --help     Show this screen.
  --version     Show version.
";

#[derive(Debug, RustcDecodable)]
struct Args {
    arg_device: String,
    arg_location: String,
    cmd_install: bool,
    cmd_mount: bool,
    cmd_unmount: bool,
    cmd_chroot: bool,
}

#[derive(Debug)]
struct Device {
    device_file: PathBuf,
    partitions: Vec<PathBuf>,
}

impl Device {
    // TODO pass errors up rather then just panicing
    fn new(device_file: String) -> Device {
        let pattern = device_file.clone() + "?[0-9]";
        Device {
            device_file: PathBuf::from(device_file),
            partitions: glob(&pattern).unwrap().map(|r| r.unwrap()).collect(),
        }
    }
}

fn main() {
    let args: Args = Docopt::new(USAGE)
                         .and_then(|d| d.decode())
                         .unwrap_or_else(|e| e.exit());
    println!("{:?}", args);

    if args.cmd_install {
        unimplemented!()
    } else if args.cmd_mount {
        let d = Device::new(args.arg_device);
        println!("{:?}", d);
    } else if args.cmd_unmount {
        unimplemented!();
        writeln!(&mut std::io::stderr(), "Error!").unwrap();
        ::std::process::exit(1)
    } else if args.cmd_chroot {
        unimplemented!()
    } else {
        unimplemented!()
    }
}
