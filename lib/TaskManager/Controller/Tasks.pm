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
# Create
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

# Edit
sub edit {
    my $c = shift;
    my $id = $c->param('id');
    my $title = $c->param('title');
    my $description = $c->param('description');
    my $status = $c->param('status');

    my $dbh = $c->db;
    $dbh->do('UPDATE tasks SET title=?, description=?, status=? WHERE id=?',
             undef, $title, $description, $status, $id);

    $c->redirect_to('/tasks');
}

# Delete
sub delete {
    my $c = shift;
    my $id = $c->param('id');

    my $dbh = $c->db;
    $dbh->do('DELETE FROM tasks WHERE id=?', undef, $id);

    $c->redirect_to('/tasks');
}
1;