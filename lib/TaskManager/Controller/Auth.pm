package TaskManager::Controller::Auth;
use Mojo::Base 'Mojolicious::Controller';

sub login_form {
    my ($c) = @_;
    $c->render(template => 'auth/login');
}

sub login {
    my ($c) = @_;

    my $username = $c->param('username');
    my $password = $c->param('password');

    my $sth = $c->db->prepare("SELECT * FROM users WHERE username = ?");
    $sth->execute($username);

    my $user = $sth->fetchrow_hashref;

    if ($user && $user->{password} eq $password) {
        $c->session(
            user_id  => $user->{id},
            username => $user->{username}
        );
        return $c->redirect_to('/tasks');
    }

    $c->flash(error => 'Invalid login');
    $c->redirect_to('/login');
}

sub logout {
    my ($c) = @_;
    $c->session(expires => 1);
    $c->redirect_to('/login');
}

1;