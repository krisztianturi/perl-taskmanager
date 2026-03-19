package TaskManager;
use Mojo::Base 'Mojolicious'; 
use DBI;

sub startup {
    my $self = shift;

    my $config = $self->plugin('NotYAMLConfig', { file => $ENV{PWD}.'/Config.yml' });
    $self->secrets($config->{secrets});

    # $self->helper(db => sub {
    # state $dbh = DBI->connect("dbi:Pg:dbname=task_db;host=localhost","dbuser","dbpass",{ RaiseError => 1, AutoCommit => 1 });
    # });

    $self->helper(db => sub {
        state $dbh = DBI->connect("dbi:Pg:dbname=$config->{dbname};host=$config->{dbhost};port=$config->{dbport}",
            $config->{dbuser},
            $config->{dbpass},
            { RaiseError => 1, AutoCommit => 1 }
        );
        return $dbh;
    });
#public route
    my $r = $self->routes;

    $r->get('/')->to('Example#welcome');

    $r->get('/login')->to('auth#login_form');
    $r->post('/login')->to('auth#login');
    $r->get('/logout')->to('auth#logout');

#safe route
    my $auth = $r->under(sub {
        my $c = shift;

        return 1 if $c->session('user_id');

        $c->redirect_to('/login');
        return undef;
    });

    $auth->get('/tasks')->to('Tasks#index');
    $auth->post('/tasks/create')->to('Tasks#create');
    $auth->post('/tasks/:id/update')->to('Tasks#update');
    $auth->post('/tasks/:id/delete')->to('Tasks#delete');


}

1;