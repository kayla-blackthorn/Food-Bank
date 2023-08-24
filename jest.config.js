const { jestConfig } = require('@salesforce/sfdx-lwc-jest/config');
module.exports = {
    ...jestConfig,
    testPathIgnorePatterns: [...jestConfig.testPathIgnorePatterns, '/__fixtures__/'],
    modulePathIgnorePatterns: ['<rootDir>/.localdevserver']
};