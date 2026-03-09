#!/bin/bash

find tests -name "*.nf.test" | parallel 'nf-test test {} --profile +apptainer --update-snapshot'
