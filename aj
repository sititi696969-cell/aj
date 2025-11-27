<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>2ezot AJ - Job Monitor</title>
    <style>
        * {
            margin: 0;
            padding: 0;
            box-sizing: border-box;
        }

        body {
            font-family: 'Segoe UI', Tahoma, Geneva, Verdana, sans-serif;
            background: linear-gradient(135deg, #0f0f23 0%, #1a1a2e 100%);
            color: #ffffff;
            min-height: 100vh;
            padding: 20px;
        }

        .container {
            max-width: 1200px;
            margin: 0 auto;
        }

        .header {
            text-align: center;
            margin-bottom: 30px;
            padding: 20px;
            background: rgba(255, 255, 255, 0.05);
            border-radius: 15px;
            backdrop-filter: blur(10px);
            border: 1px solid rgba(255, 255, 255, 0.1);
        }

        .header h1 {
            font-size: 2.5em;
            margin-bottom: 10px;
            background: linear-gradient(45deg, #ff6b6b, #4ecdc4);
            -webkit-background-clip: text;
            -webkit-text-fill-color: transparent;
        }

        .status-bar {
            display: flex;
            justify-content: space-between;
            align-items: center;
            margin-bottom: 20px;
            padding: 15px;
            background: rgba(255, 255, 255, 0.05);
            border-radius: 10px;
            border: 1px solid rgba(255, 255, 255, 0.1);
        }

        .connection-status {
            display: flex;
            align-items: center;
            gap: 10px;
        }

        .status-dot {
            width: 10px;
            height: 10px;
            border-radius: 50%;
            background: #ff4757;
        }

        .status-dot.connected {
            background: #2ed573;
        }

        .controls {
            display: flex;
            gap: 10px;
        }

        button {
            padding: 8px 16px;
            border: none;
            border-radius: 5px;
            background: linear-gradient(45deg, #3742fa, #5352ed);
            color: white;
            cursor: pointer;
            font-weight: bold;
            transition: all 0.3s ease;
        }

        button:hover {
            transform: translateY(-2px);
            box-shadow: 0 5px 15px rgba(55, 66, 250, 0.4);
        }

        button:disabled {
            background: #6c757d;
            cursor: not-allowed;
            transform: none;
            box-shadow: none;
        }

        .jobs-grid {
            display: grid;
            grid-template-columns: repeat(auto-fill, minmax(350px, 1fr));
            gap: 20px;
            margin-bottom: 20px;
        }

        .job-card {
            background: rgba(255, 255, 255, 0.05);
            border-radius: 10px;
            padding: 20px;
            border: 1px solid rgba(255, 255, 255, 0.1);
            transition: all 0.3s ease;
            backdrop-filter: blur(10px);
        }

        .job-card:hover {
            transform: translateY(-5px);
            border-color: #3742fa;
            box-shadow: 0 10px 30px rgba(0, 0, 0, 0.3);
        }

        .job-card.high-value {
            border-color: #ffa502;
            background: linear-gradient(135deg, rgba(255, 165, 2, 0.1), rgba(255, 165, 2, 0.05));
        }

        .job-header {
            display: flex;
            justify-content: space-between;
            align-items: center;
            margin-bottom: 15px;
        }

        .pet-name {
            font-size: 1.2em;
            font-weight: bold;
            color: #4ecdc4;
        }

        .money {
            font-size: 1.3em;
            font-weight: bold;
            color: #2ed573;
        }

        .job-id {
            font-family: 'Courier New', monospace;
            background: rgba(0, 0, 0, 0.3);
            padding: 8px 12px;
            border-radius: 5px;
            margin: 10px 0;
            word-break: break-all;
            font-size: 0.9em;
        }

        .job-meta {
            display: flex;
            justify-content: space-between;
            font-size: 0.9em;
            color: #a4b0be;
            margin-bottom: 15px;
        }

        .join-btn {
            width: 100%;
            padding: 12px;
            background: linear-gradient(45deg, #2ed573, #1dd1a1);
            font-size: 1em;
        }

        .join-btn:hover {
            background: linear-gradient(45deg, #26c56a, #17b894);
        }

        .logs {
            background: rgba(0, 0, 0, 0.3);
            border-radius: 10px;
            padding: 20px;
            border: 1px solid rgba(255, 255, 255, 0.1);
            max-height: 300px;
            overflow-y: auto;
        }

        .logs h3 {
            margin-bottom: 15px;
            color: #ffa502;
        }

        .log-entry {
            padding: 8px 0;
            border-bottom: 1px solid rgba(255, 255, 255, 0.1);
            font-family: 'Courier New', monospace;
            font-size: 0.9em;
        }

        .log-time {
            color: #a4b0be;
            margin-right: 10px;
        }

        @media (max-width: 768px) {
            .jobs-grid {
                grid-template-columns: 1fr;
            }
            
            .status-bar {
                flex-direction: column;
                gap: 10px;
                text-align: center;
            }
        }
    </style>
</head>
<body>
    <div class="container">
        <div class="header">
            <h1>2ezot AJ - Job Monitor</h1>
            <p>Real-time job monitoring from Discord channels</p>
        </div>

        <div class="status-bar">
            <div class="connection-status">
                <div class="status-dot" id="statusDot"></div>
                <span id="statusText">Disconnected</span>
            </div>
            <div class="controls">
                <button id="connectBtn" onclick="connectWebSocket()">Connect</button>
                <button id="clearBtn" onclick="clearLogs()">Clear Logs</button>
            </div>
        </div>

        <div class="jobs-grid" id="jobsGrid">
            <div class="job-card placeholder">
                <p>Waiting for jobs to appear...</p>
            </div>
        </div>

        <div class="logs">
            <h3>Activity Log</h3>
            <div id="logContainer"></div>
        </div>
    </div>

    <script>
        let ws = null;
        let jobs = new Map();
        let serverIP = 'localhost'; // Change this to your server IP

        function log(message, type = 'info') {
            const logContainer = document.getElementById('logContainer');
            const timestamp = new Date().toLocaleTimeString();
            const logEntry = document.createElement('div');
            logEntry.className = 'log-entry';
            logEntry.innerHTML = `<span class="log-time">[${timestamp}]</span> ${message}`;
            
            if (type === 'error') {
                logEntry.style.color = '#ff4757';
            } else if (type === 'success') {
                logEntry.style.color = '#2ed573';
            } else if (type === 'warning') {
                logEntry.style.color = '#ffa502';
            }
            
            logContainer.appendChild(logEntry);
            logContainer.scrollTop = logContainer.scrollHeight;
        }

        function updateStatus(connected) {
            const statusDot = document.getElementById('statusDot');
            const statusText = document.getElementById('statusText');
            const connectBtn = document.getElementById('connectBtn');
            
            if (connected) {
                statusDot.className = 'status-dot connected';
                statusText.textContent = 'Connected';
                connectBtn.textContent = 'Disconnect';
                connectBtn.onclick = disconnectWebSocket;
            } else {
                statusDot.className = 'status-dot';
                statusText.textContent = 'Disconnected';
                connectBtn.textContent = 'Connect';
                connectBtn.onclick = connectWebSocket;
            }
        }

        function connectWebSocket() {
            if (ws && ws.readyState === WebSocket.OPEN) {
                return;
            }

            try {
                const wsUrl = `ws://${serverIP}:1488`;
                ws = new WebSocket(wsUrl);
                log(`Connecting to ${wsUrl}...`, 'info');

                ws.onopen = function() {
                    log('WebSocket connection established', 'success');
                    updateStatus(true);
                };

                ws.onmessage = function(event) {
                    try {
                        const data = JSON.parse(event.data);
                        handleJobData(data);
                    } catch (error) {
                        log('Error parsing message: ' + error, 'error');
                    }
                };

                ws.onclose = function() {
                    log('WebSocket connection closed', 'warning');
                    updateStatus(false);
                    // Attempt to reconnect after 5 seconds
                    setTimeout(connectWebSocket, 5000);
                };

                ws.onerror = function(error) {
                    log('WebSocket error: ' + error, 'error');
                    updateStatus(false);
                };

            } catch (error) {
                log('Failed to create WebSocket: ' + error, 'error');
                updateStatus(false);
            }
        }

        function disconnectWebSocket() {
            if (ws) {
                ws.close();
                ws = null;
            }
            updateStatus(false);
            log('Disconnected from server', 'warning');
        }

        function handleJobData(data) {
            if (!data.jobid) return;

            // Store job data
            jobs.set(data.jobid, {
                ...data,
                timestamp: new Date(),
                money: parseFloat(data.money) || 0
            });

            // Update UI
            updateJobsGrid();
            
            // Log the job
            const moneyStr = formatMoney(data.money);
            log(`New job: ${data.name} - ${moneyStr}/s - ${data.jobid}`, 'success');
        }

        function formatMoney(money) {
            const num = parseFloat(money) || 0;
            if (num >= 1000000) {
                return `$${(num / 1000000).toFixed(1)}M`;
            } else if (num >= 1000) {
                return `$${(num / 1000).toFixed(1)}K`;
            } else {
                return `$${num}`;
            }
        }

        function updateJobsGrid() {
            const jobsGrid = document.getElementById('jobsGrid');
            
            if (jobs.size === 0) {
                jobsGrid.innerHTML = '<div class="job-card placeholder"><p>Waiting for jobs to appear...</p></div>';
                return;
            }

            // Convert to array and sort by money (highest first)
            const jobsArray = Array.from(jobs.values())
                .sort((a, b) => b.money - a.money);

            jobsGrid.innerHTML = jobsArray.map(job => `
                <div class="job-card ${job.money >= 1000000 ? 'high-value' : ''}">
                    <div class="job-header">
                        <div class="pet-name">${job.name || 'Unknown Pet'}</div>
                        <div class="money">${formatMoney(job.money)}/s</div>
                    </div>
                    <div class="job-id">${job.jobid}</div>
                    <div class="job-meta">
                        <span>Received: ${job.timestamp.toLocaleTimeString()}</span>
                        <span>${job.money >= 1000000 ? '💎 HIGH VALUE' : ''}</span>
                    </div>
                    <button class="join-btn" onclick="joinJob('${job.jobid}')">
                        JOIN JOB
                    </button>
                </div>
            `).join('');
        }

        function joinJob(jobId) {
            log(`Attempting to join job: ${jobId}`, 'info');
            
            // Roblox deep link format
            const placeId = "109983668079237"; // Pet Simulator 99 place ID
            const url = `roblox://placeId=${placeId}&gameInstanceId=${jobId}`;
            
            // Try to open Roblox
            window.location.href = url;
            
            // Fallback: open in browser
            setTimeout(() => {
                const confirmed = confirm(
                    `Join job: ${jobId}\n\n` +
                    `If Roblox didn't open, click OK to open in browser.`
                );
                if (confirmed) {
                    window.open(`https://www.roblox.com/games/${placeId}?gameInstanceId=${jobId}`, '_blank');
                }
            }, 1000);
        }

        function clearLogs() {
            document.getElementById('logContainer').innerHTML = '';
            log('Logs cleared', 'info');
        }

        // Auto-connect when page loads
        window.addEventListener('load', function() {
            log('Page loaded - ready to connect', 'info');
            connectWebSocket();
        });

        // Reconnect if connection is lost
        window.addEventListener('online', function() {
            log('Browser is back online', 'success');
            connectWebSocket();
        });

        window.addEventListener('offline', function() {
            log('Browser is offline', 'warning');
        });
    </script>
</body>
</html>
