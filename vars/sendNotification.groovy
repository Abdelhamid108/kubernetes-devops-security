def call(String buildStatus = 'STARTED') {
    // Fallback to SUCCESS if undefined
    buildStatus = buildStatus ?: 'SUCCESS'

    // Choose color by status
    def color = (buildStatus == 'SUCCESS') ? '#47ec05' :
                (buildStatus == 'UNSTABLE') ? '#5eeded' : '#ec2805'

    // Build the message
    def msg = "*${buildStatus}* `${env.JOB_NAME}` #${env.BUILD_NUMBER}\n${env.BUILD_URL}"

    // Send to Slack
    slackSend(color: color, message: msg)
}