package TaskManager::Controller::Tasks;
use Mojo::Base 'Mojolicious::Controller';

sub index {
    my $c = shift;
    $c->render(text => 'Tasks page');
}

1;