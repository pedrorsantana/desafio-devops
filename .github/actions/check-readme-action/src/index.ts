import * as core from '@actions/core';
import * as fs from 'fs';

async function run() {
  if (!fs.existsSync('README.md')) {
    core.setFailed('README.md não encontrado. Abortando pipeline.');
  } else {
    core.info('README.md encontrado.');
  }
}

run();
