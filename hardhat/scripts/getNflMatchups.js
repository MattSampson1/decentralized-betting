const axios = require("axios");

const args = process.argv.slice(2);
const year = args[0] || "2024";

const config = {
    url: `https://site.api.espn.com/apis/site/v2/sports/football/nfl/scoreboard?limit=1000&dates=${year}`,
};

async function getWeeklyMatchups() {
    try {
        const response = await axios(config);

        if (response.status !== 200) {
            throw new Error(`Request failed with status code ${response.status}`);
        }

        // console.log("API Response:", response.data); // Log the entire response for debugging

        if (!response.data || !response.data.events) {
            throw new Error("No data returned from API");
        }

        // Extract all weekly matchups
        const matchups = response.data.events.map((event) => {
            const homeTeam = event.competitions[0].competitors.find(
                (comp) => comp.homeAway === "home",
            )?.team.displayName;
            const awayTeam = event.competitions[0].competitors.find(
                (comp) => comp.homeAway === "away",
            )?.team.displayName;
            return {
                id: event.id,
                date: event.date,
                matchup: `${awayTeam} @ ${homeTeam}`,
            };
        });

        console.log("Weekly Matchups:", matchups);
    } catch (error) {
        console.error("Error:", error.message);
        throw error;
    }
}

getWeeklyMatchups();
