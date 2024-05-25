const year = args[0];
const matchId = args[1]; // Example ID for the specific matchup

const config = {
    url: `https://site.api.espn.com/apis/site/v2/sports/football/nfl/scoreboard?limit=100&dates=${year}`,
};

try {
    const response = await Functions.makeHttpRequest(config);

    if (response.status !== 200) {
        throw new Error(`Request failed with status code ${response.status}`);
    }

    // console.log("API Response:", response.data); // Log the entire response for debugging

    if (!response.data || !response.data.events) {
        throw new Error("No data returned from API");
    }

    // Find the specific event by ID
    const match = response.data.events.find((event) => event.id === matchId);

    if (!match) {
        console.log("Match not found for given ID");
        throw new Error("Match not found for given ID");
    }

    const homeCompetitor = match.competitions[0].competitors.find(
        (comp) => comp.homeAway === "home",
    );
    const awayCompetitor = match.competitions[0].competitors.find(
        (comp) => comp.homeAway === "away",
    );

    let result;

    if (homeCompetitor.winner) {
        result = homeCompetitor.team.abbreviation;
    } else if (awayCompetitor.winner) {
        result = awayCompetitor.team.abbreviation;
    } else {
        result = "Draw"; // need to fix this so that if the game has not happened it doesn't print draw!
    }

    if (!result) {
        console.log("Could not get the winner team");
        throw new Error("Could not get the winner team.");
    }

    console.log("Winner:", result);
    return Functions.encodeString(result);
} catch (error) {
    console.error("Error:", error.message);
    throw error;
}
