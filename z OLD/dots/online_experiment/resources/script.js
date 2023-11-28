/******************************************************************************
 * DESCRIPTION
 ******************************************************************************
 *
 * This script keeps a running record of responses during the task and randomly
 * selects one from each condition to determine a bonus payment. The bonus
 * amounts and total bonus are shown on a subsequent display of the same task.
 * The details of the bonus (trial number, condition, amount) are also saved to
 * the data spreadsheet.
 * 
 * See section REQUIREMENTS below for details on the required task structure.
 */
​
​
/******************************************************************************
 * REQUIREMENTS
 ******************************************************************************
 *
 * The task must have at least two displays:
 * - one where the response is recorded for each trial
 * - one where the bonus message is shown after all trials in the task are
 *   complete.
 * Each display must contain at least one screen.
 * 
 * On the screen where the participant responds, it must be recorded in the
 * task's embedded data with a value of 'left' or 'right'. Any other value
 * will result in a bonus of 0 for that trial.
 * 
 * On the screen where the bonus is displayed, there must be a single rich text
 * element. Its content doesn't matter as this script will overwrite it with
 * the bonus message.
 * 
 * The section USER SETTINGS below must be filled out with the correct display
 * names, etc. for the task.
 * 
 * The task spreadsheet must contain the additional columns
 * - `condition` (string): Block condition name
 * - `Lev` (number): Bonus amount if participant chooses left
 * - `Rev` (number): Bonus amount if participant chooses right
 */
​
​
/******************************************************************************
 * USER SETTINGS
 *****************************************************************************/
​
// Display names & screen indices
// Remember, screen index starts at 0!
​
// Display name where answer is recorded
const TRIAL_DISPLAY = 'Trial';
​
// Screen index where answer is recorded
const TRIAL_SCREEN = 1;
​
// Display name where bonus is shown
const BONUS_DISPLAY = 'End';
​
// Screen index where bonus is shown
const BONUS_SCREEN = 0;
​
// ----------------------------------------------------------------------------
​
// Other vars
​
// Name of embedded variable where response is stored; this is set under
// Task Structure on display TRIAL_DISPLAY and screen TRIAL_SCREEN
const EMBEDDED_RESPONSE = 'responseVar';
​
// HTML to display on bonus page, where '%s' is replaced by bonuses
const BONUS_HTML = 
    `<span class="centered">
        <h1>
            Your bonuses:
        </h1>
​
        %s
        
        <p>
            Please allow up to 3 business days for processing.
        </p>
    </span>`;
​
// HTML to display on bonus page in case of an error
const ERROR_HTML =
    `<span class="centered">
        <p>
            There has been an error processing your bonuses.
            Please contact us.
        </p>
    </span>`;
​
​
/******************************************************************************
 * CODE
 *****************************************************************************/
​
// Helper functions
​
// Shorthand for storing notes in data
// Args will be recorded in a dedicated row of the data sheet, with the
// `label` under column "Response Type" and `value` under "Response"
function logLine(label, value) {
    gorilla.metric({
        response_type: label,
        response: value
    });
}
​
// Capitalize the first letter of a string
function capitalize(str) {
    return str.charAt(0).toUpperCase() + str.slice(1);
}
​
// Format number as dollars and cents
function formatBonus(b) {
    if (b < 0) {
        b = -b
        return `&ndash;$${b.toFixed(2)}`
    } else {
        return `$${b.toFixed(2)}`
    }
}
​
// ----------------------------------------------------------------------------
​
// Store each trial's choice
gorillaTaskBuilder.onScreenFinish((spreadsheet: any, rowIndex: number,
    screenIndex: number, row: any, container: string, correct: boolean) => {
    // Store each response at the end of the response screen
    // including timeouts/no response
    if (row.display == TRIAL_DISPLAY && screenIndex == TRIAL_SCREEN) {
        const lastResponse = gorilla.retrieve(EMBEDDED_RESPONSE, null, true);
        var lastBonus;
        if (lastResponse == 'left') {
            lastBonus = row.Lev;
        } else if (lastResponse == 'right') {
            lastBonus = row.Rev;
        } else {
            lastBonus = 0;
        }
        var allResponses = gorilla.retrieve('allResponses', {}, true);
        if (!(row.condition in allResponses)) {
            allResponses[row.condition] = [];
        }
        allResponses[row.condition].push({
            response: lastResponse,
            bonus: lastBonus,
            trial_number: row.trial_number
        });
        gorilla.store('allResponses', allResponses, true);
    }
});
​
​
// Get and display the bonuses at the end of the experiment
gorillaTaskBuilder.onScreenStart((spreadsheet: any, rowIndex: number,
    screenIndex: number, row: any, container: string) => {
    // Select random bonus and display result at end of task
    if (row.display == BONUS_DISPLAY && screenIndex == BONUS_SCREEN) {
        let allResponses = gorilla.retrieve('allResponses', null, true);
        let bonusHtml;
        if (allResponses == null) { // Couldn't retrieve allResponses
            bonusHtml = ERROR_HTML;
        } else {
            bonusHtml = BONUS_HTML
            let totalBonus = 0.0;
            let bonusInnerHtml = '';
            for (let condition in allResponses) {
                let thisCondition = allResponses[condition];
                let randomTrial = Math.floor(
                    Math.random() * thisCondition.length);
                let randomResult = thisCondition[randomTrial];
                let bonusAmount = Math.round( // Round to cents before summing
                    parseFloat(randomResult.bonus) * 100) / 100;
                bonusInnerHtml +=
                    `<h2>
                        ${capitalize(condition)}: ${formatBonus(bonusAmount)}
                    </h2>`;
                totalBonus += bonusAmount;
                // Store the bonus details in the task data
                logLine('Bonus Condition', condition);
                logLine('Bonus Trial', randomResult.trial_number);
                logLine('Bonus Amount', bonusAmount);
            }
            bonusInnerHtml += 
                `<h1>
                    Total: ${formatBonus(totalBonus)}
                </h1>`;
            bonusHtml = bonusHtml.replace('%s', bonusInnerHtml);
        }
        $(container + ' .content').html(bonusHtml);
        gorilla.refreshLayout(); // Recalculate page layout with our new HTML
    }
    
    
    // ------------------------------------------------------------------------
    // Experiment Settings
    // ------------------------------------------------------------------------
    
    // Font size
    $('h1').css('font-size', 40); //titles
    $('h2').css('font-size', 32); //regular text
    $('p, span').css('font-size', 24); //stimuli
    
    // Color
    $('body').css('background-color', '#000'); //black
    $('h1, h2, h4, h5, p, span').css('color', '#fff'); //white
    
});
