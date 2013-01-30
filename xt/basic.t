use strict;
use warnings;

use RT::Extension::NonWatcherRecipients::Test tests => undef;

use_ok('RT::Extension::NonWatcherRecipients');

{

    my $user = RT::User->new(RT->SystemUser);
    $user->Load('root');
    $user->SetEmailAddress('root@example.com');

    my $curr_user = RT::CurrentUser->new($user);

    my $t = RT::Ticket->new($curr_user);
    my ($id, $msg) = $t->Create(
        Queue => 'General',
        Subject => 'Test ticket',
        Content => 'This is a test',
        Requestor => ['root'],
        );

    ok( $t->id, 'Create test ticket: ' . $t->id);

    my ($txn_id, $txn_msg, $txn_obj) = $t->Correspond(
         CcMessageTo => 'sharkbanana@bestpractical.com',
         Content => 'This is a test' );

    ok( $txn_id, "Created transaction: $txn_id $txn_msg");

    my $message = RT::Extension::NonWatcherRecipients->FindRecipients(
        Transaction => $txn_obj,
        Ticket => $t);

    like( $message, qr/The following people received a copy/, 'Got message');
    like( $message, qr/sharkbanana\@bestpractical\.com/, 'Got email address');
}

done_testing;
