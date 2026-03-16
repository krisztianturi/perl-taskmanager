package TaskManager;
use Mojo::Base 'Mojolicious'; 
use DBI;

sub startup {
    my $self = shift;

    # Load configuration
    my $config = $self->plugin('NotYAMLConfig', { file => $ENV{PWD}.'/Config.yml' });

    # Configure secrets
    $self->secrets($config->{secrets});

    # # DB helper
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

    # Router
    my $r = $self->routes;
    $r->get('/')->to('Example#welcome');
    $r->get('/tasks')->to('Tasks#index');
    # Új feladat létrehozása
    $r->post('/tasks/create')->to('Tasks#create');

    # Feladat szerkesztése
    $r->post('/tasks/:id/update')->to('Tasks#update');

    # Feladat törlése
    $r->post('/tasks/:id/delete')->to('Tasks#delete');
}

1;