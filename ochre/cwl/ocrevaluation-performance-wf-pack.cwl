{
    "cwlVersion": "v1.0", 
    "$graph": [
        {
            "class": "CommandLineTool", 
            "baseCommand": [
                "python", 
                "-m", 
                "nlppln.commands.ls"
            ], 
            "doc": "List files in a directory.\n\nThis command can be used to convert a ``Directory`` into a list of files. This list can be filtered on file name by specifying ``--endswith``.\n", 
            "inputs": [
                {
                    "type": [
                        "null", 
                        "string"
                    ], 
                    "inputBinding": {
                        "prefix": "--endswith"
                    }, 
                    "id": "#ls.cwl/endswith"
                }, 
                {
                    "type": "Directory", 
                    "inputBinding": {
                        "position": 2
                    }, 
                    "id": "#ls.cwl/in_dir"
                }, 
                {
                    "type": [
                        "null", 
                        "boolean"
                    ], 
                    "inputBinding": {
                        "prefix": "--recursive"
                    }, 
                    "id": "#ls.cwl/recursive"
                }
            ], 
            "stdout": "cwl.output.json", 
            "outputs": [
                {
                    "type": {
                        "type": "array", 
                        "items": "File"
                    }, 
                    "id": "#ls.cwl/out_files"
                }
            ], 
            "id": "#ls.cwl"
        }, 
        {
            "class": "CommandLineTool", 
            "baseCommand": [
                "python", 
                "-m", 
                "nlppln.commands.merge_csv"
            ], 
            "requirements": [
                {
                    "listing": "$(inputs.in_files)", 
                    "class": "InitialWorkDirRequirement"
                }
            ], 
            "arguments": [
                {
                    "valueFrom": "$(runtime.outdir)", 
                    "position": 1
                }
            ], 
            "doc": "Merge csv files (with the same header) into a single csv file.", 
            "inputs": [
                {
                    "type": {
                        "type": "array", 
                        "items": "File"
                    }, 
                    "id": "#merge-csv.cwl/in_files"
                }, 
                {
                    "type": [
                        "null", 
                        "string"
                    ], 
                    "default": "merged.csv", 
                    "inputBinding": {
                        "prefix": "--name=", 
                        "separate": false
                    }, 
                    "id": "#merge-csv.cwl/name"
                }
            ], 
            "outputs": [
                {
                    "type": "File", 
                    "outputBinding": {
                        "glob": "$(inputs.name)"
                    }, 
                    "id": "#merge-csv.cwl/merged"
                }
            ], 
            "id": "#merge-csv.cwl"
        }, 
        {
            "class": "CommandLineTool", 
            "baseCommand": [
                "python", 
                "-m", 
                "ochre.ocrevaluation_extract"
            ], 
            "inputs": [
                {
                    "type": "File", 
                    "inputBinding": {
                        "position": 1
                    }, 
                    "id": "#ocrevaluation-extract.cwl/in_file"
                }
            ], 
            "outputs": [
                {
                    "type": "File", 
                    "outputBinding": {
                        "glob": "*-character.csv"
                    }, 
                    "id": "#ocrevaluation-extract.cwl/character_data"
                }, 
                {
                    "type": "File", 
                    "outputBinding": {
                        "glob": "*-global.csv"
                    }, 
                    "id": "#ocrevaluation-extract.cwl/global_data"
                }
            ], 
            "id": "#ocrevaluation-extract.cwl"
        }, 
        {
            "class": "Workflow", 
            "requirements": [
                {
                    "class": "ScatterFeatureRequirement"
                }
            ], 
            "inputs": [
                {
                    "type": "Directory", 
                    "id": "#main/gt"
                }, 
                {
                    "type": "Directory", 
                    "id": "#main/ocr"
                }, 
                {
                    "default": "performance.csv", 
                    "type": [
                        "null", 
                        "string"
                    ], 
                    "id": "#main/out_name"
                }
            ], 
            "outputs": [
                {
                    "type": "File", 
                    "outputSource": "#main/merge-csv-1/merged", 
                    "id": "#main/performance"
                }
            ], 
            "steps": [
                {
                    "run": "#ls.cwl", 
                    "in": [
                        {
                            "source": "#main/ocr", 
                            "id": "#main/ls-6/in_dir"
                        }
                    ], 
                    "out": [
                        "#main/ls-6/out_files"
                    ], 
                    "id": "#main/ls-6"
                }, 
                {
                    "run": "#ls.cwl", 
                    "in": [
                        {
                            "source": "#main/gt", 
                            "id": "#main/ls-7/in_dir"
                        }
                    ], 
                    "out": [
                        "#main/ls-7/out_files"
                    ], 
                    "id": "#main/ls-7"
                }, 
                {
                    "run": "#merge-csv.cwl", 
                    "in": [
                        {
                            "source": "#main/ocrevaluation-extract-1/global_data", 
                            "id": "#main/merge-csv-1/in_files"
                        }, 
                        {
                            "source": "#main/out_name", 
                            "id": "#main/merge-csv-1/name"
                        }
                    ], 
                    "out": [
                        "#main/merge-csv-1/merged"
                    ], 
                    "id": "#main/merge-csv-1"
                }, 
                {
                    "run": "#ocrevaluation.cwl", 
                    "in": [
                        {
                            "source": "#main/ls-7/out_files", 
                            "id": "#main/ocrevaluation-1/gt"
                        }, 
                        {
                            "source": "#main/ls-6/out_files", 
                            "id": "#main/ocrevaluation-1/ocr"
                        }
                    ], 
                    "out": [
                        "#main/ocrevaluation-1/out_file"
                    ], 
                    "scatter": [
                        "#main/ocrevaluation-1/gt", 
                        "#main/ocrevaluation-1/ocr"
                    ], 
                    "scatterMethod": "dotproduct", 
                    "id": "#main/ocrevaluation-1"
                }, 
                {
                    "run": "#ocrevaluation-extract.cwl", 
                    "in": [
                        {
                            "source": "#main/ocrevaluation-1/out_file", 
                            "id": "#main/ocrevaluation-extract-1/in_file"
                        }
                    ], 
                    "out": [
                        "#main/ocrevaluation-extract-1/character_data", 
                        "#main/ocrevaluation-extract-1/global_data"
                    ], 
                    "scatter": [
                        "#main/ocrevaluation-extract-1/in_file"
                    ], 
                    "scatterMethod": "dotproduct", 
                    "id": "#main/ocrevaluation-extract-1"
                }
            ], 
            "id": "#main"
        }, 
        {
            "class": "CommandLineTool", 
            "baseCommand": [
                "java", 
                "-cp", 
                "/ocrevalUAtion/target/ocrevaluation.jar", 
                "eu.digitisation.Main"
            ], 
            "requirements": [
                {
                    "class": "DockerRequirement", 
                    "dockerPull": "nlppln/ocrevaluation-docker"
                }
            ], 
            "arguments": [
                {
                    "prefix": "-o", 
                    "valueFrom": "$(runtime.outdir)/$(inputs.gt.nameroot)_out.html"
                }
            ], 
            "inputs": [
                {
                    "type": [
                        "null", 
                        "string"
                    ], 
                    "inputBinding": {
                        "prefix": "-e"
                    }, 
                    "id": "#ocrevaluation.cwl/encoding"
                }, 
                {
                    "type": "File", 
                    "inputBinding": {
                        "prefix": "-gt"
                    }, 
                    "id": "#ocrevaluation.cwl/gt"
                }, 
                {
                    "type": [
                        "null", 
                        "boolean"
                    ], 
                    "inputBinding": {
                        "prefix": "-ic"
                    }, 
                    "id": "#ocrevaluation.cwl/ignore_case"
                }, 
                {
                    "type": [
                        "null", 
                        "boolean"
                    ], 
                    "inputBinding": {
                        "prefix": "-id"
                    }, 
                    "id": "#ocrevaluation.cwl/ignore_diacritics"
                }, 
                {
                    "type": [
                        "null", 
                        "boolean"
                    ], 
                    "inputBinding": {
                        "prefix": "-ip"
                    }, 
                    "id": "#ocrevaluation.cwl/ignore_punctuation"
                }, 
                {
                    "type": "File", 
                    "inputBinding": {
                        "prefix": "-ocr"
                    }, 
                    "id": "#ocrevaluation.cwl/ocr"
                }
            ], 
            "outputs": [
                {
                    "type": "File", 
                    "outputBinding": {
                        "glob": "$(inputs.gt.nameroot)_out.html"
                    }, 
                    "id": "#ocrevaluation.cwl/out_file"
                }
            ], 
            "id": "#ocrevaluation.cwl"
        }
    ]
}