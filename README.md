# netwatch
MKT Netwatch similar


Usage:
    netwatch [options]

     Options:
            -host|h host        Hostname to monitor (required)
            -timeout|t seconds  Monitor timeout 
            -interval|i seconds Check interval
            -retries|r retries  Check retries
            -up-script|u cmd    Host up command (required)
            -down-script|d cmd  Host down command (required)
            -verbose|v          Print State and operations on console
            -daemon|b           Background process, could not be used with verbose
            -help               Brief help message
            -man                Full documentation

Options:

    -host   Hostname to monitor

    -timeout
            Seconds before consider a test fail

    -interval
            Seconds between checks

    -retries
            Number of checks before consider host down

    -up-script
            Script to run when host is up

    -down-script
            Script to run hen host is down

    -verbose
            Print state and operations on console

    -daemon Send process to background. Could not be used with verbose

    -help   Print a brief help message and exits.

    -man    Prints the manual page and exits.

