package TaskManager::Controller::Tasks;
use Mojo::Base 'Mojolicious::Controller';

sub index {
    my $c = shift;

    # Példa: a DB-ből lekérjük a feladatokat
    my $dbh = $c->db;
    my $sth = $dbh->prepare("SELECT * FROM tasks ORDER BY id");
    $sth->execute;
    my @tasks;
    while (my $row = $sth->fetchrow_hashref) {
        push @tasks, $row;
    }

    # Változó átadása a template-nek
    $c->render(template => 'tasks/index', tasks => \@tasks);
}

sub create {
    my $c = shift;
    my $title = $c->param('title');
    my $description = $c->param('description');
    my $status = $c->param('status') // 'open';

    my $dbh = $c->db;
    $dbh->do('INSERT INTO tasks (title, description, status) VALUES (?, ?, ?)',
             undef, $title, $description, $status);

    $c->redirect_to('/tasks');
}

sub update {
    my ($c) = @_;

    my $id     = $c->param('id');
    my $title  = $c->param('title');
    my $desc   = $c->param('description');
    my $status = $c->param('status');

    unless ($title) {
        $c->flash(error => 'Title is required');
        return $c->redirect_to('/tasks');
    }

    my $sth = $c->db->prepare(
        'UPDATE tasks SET title=?, description=?, status=? WHERE id=?'
    );
    $sth->execute($title, $desc, $status, $id);

    $c->redirect_to('/tasks');
}

sub delete {
    my $c = shift;
    my $id = $c->param('id');

    my $dbh = $c->db;
    $dbh->do('DELETE FROM tasks WHERE id=?', undef, $id);

    $c->redirect_to('/tasks');
}
1;