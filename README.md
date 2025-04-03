# containerize_apptainer

Scripts to assist with common application container constructions 
using apptainer. 

**IMPORTANT** The script, `containerize_apptainer.sh`, will look for a .def fiel 
and if finds one, it will open the .def on file. The `containerize_apptainer.sh` will not
overwrite the customizations you have made to the `$APP_NAME.def` file. If the --build flag 
is used and a `$APP_NAME.sif` already exists, the script issues a warning that it will be overwriten.


## First steps

- Create, or use an existing non-LDAP user to build containers. If you
    need to create one, do something like this:

```bash
UID_BASE=200000
COUNT=65536

useradd -m pyxidarius
usermod -aG wheel pyxidarius
usermod --add-subuids ${UID_BASE}-${COUNT} pyxidarius
usermod --add-subgids ${UID_BASE}-${COUNT} pyxidarius
```

- Enable the user to run containers even when not logged in.

```bash
loginctl enable-linger pyxidarius
```

- Login as the new user (pyxidarius), and run
```bash
./containerize_apptainer.sh mycontainername --build
```

- The script will create a `build-$APP_NAME` where the definition will be stored. The container 
    will be build in `build-$APP_NAME`
- The directory will be created in the directory where `containerize_apptainer.sh` is..
- Run this script with an argument that will be the name of the container.

```bash
./containerize.sh mycontainername
```

You will have the directory `build-$APP_NAME` and the file `$APP_NAME.def`, and the editor
will open the `$APP_NAME.def` for editing.

```bash
├── build-cowsay
│   └── cowsay.def
└── cowsay.sif
```
The following command will attempt to build the container.

```bash
./containerize.sh mycontainername --build
```

