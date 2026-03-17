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

    my $r = $self->routes;
    $r->get('/')->to('Example#welcome');
    $r->get('/tasks')->to('Tasks#index');
    $r->post('/tasks/create')->to('Tasks#create');
    $r->post('/tasks/:id/update')->to('Tasks#update');
    $r->post('/tasks/:id/delete')->to('Tasks#delete');
}

1;