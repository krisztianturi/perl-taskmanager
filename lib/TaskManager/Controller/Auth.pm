package TaskManager::Controller::Auth;
use Mojo::Base 'Mojolicious::Controller';
use Crypt::Bcrypt qw(bcrypt bcrypt_check);

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

    if ($user && bcrypt($password, $user->{password})) {
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

sub register_form {
    my ($c) = @_;
    $c->render(template => 'auth/register');
}

sub register {
    my ($c) = @_;

    my $username = $c->param('username');
    my $password = $c->param('password');

    unless ($username && $password) {
        $c->flash(error => 'All fields required');
        return $c->redirect_to('/register');
    }

    my $dbh = $c->db;

    my $sth = $dbh->prepare("SELECT id FROM users WHERE username = ?");
    $sth->execute($username);

    if ($sth->fetchrow_hashref) {
        $c->flash(error => 'Username already exists');
        return $c->redirect_to('/register');
    }

    my $hash = bcrypt($password);

    my $insert = $dbh->prepare(
        "INSERT INTO users (username, password) VALUES (?, ?)"
    );
    $insert->execute($username, $hash);

    $c->flash(message => 'Registration successful');
    $c->redirect_to('/login');
}

1;