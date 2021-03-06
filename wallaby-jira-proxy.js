module.exports = function (wallaby) {
    return {
        files: [
            'node/jira-issues/src/**/*.coffee',
            'node/jira-mappings/src/**/*.coffee',
            'node/jira-proxy/src/**/*.coffee'
        ],

        tests: [
            'node/jira-proxy/test/**/*.coffee'
        ],
        compilers: {
            '**/*.js?(x)': wallaby.compilers.babel({}),
        },
        env: {
            type: 'node',
            runner: 'node'
        }
    }
}