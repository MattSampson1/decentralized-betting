const year = args[0];
const date = args[1]; // Example date in the format YYYY-MM-DD
const teams = args[2]; // Example teams in the format TEAM1/TEAM2

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

    // Filter events by the specific date
    const allMatches = response.data.events.filter((event) => event.date.startsWith(date));

    if (!allMatches || allMatches.length === 0) {
        console.log("No matches found for the given date");
        throw new Error("No matches found for the given date");
    }

    const match = allMatches.find((event) => {
        const homeTeam = event.competitions[0].competitors.find((comp) => comp.homeAway === "home")
            .team.abbreviation;
        const awayTeam = event.competitions[0].competitors.find((comp) => comp.homeAway === "away")
            .team.abbreviation;
        const playingTeams = `${awayTeam}/${homeTeam}`.toUpperCase();
        const playingTeamsReversed = `${homeTeam}/${awayTeam}`.toUpperCase();

        return teams.toUpperCase() === playingTeams || teams.toUpperCase() === playingTeamsReversed;
    });

    if (!match) {
        console.log("Match not found for given arguments");
        throw new Error("Match not found for given arguments");
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
        result = "Draw";
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
