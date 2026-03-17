package TaskManager::Controller::Tasks;
use Mojo::Base 'Mojolicious::Controller';

sub index {
    my ($c) = @_;

    my $status = $c->param('status');
    my $q      = $c->param('q');

    my $dbh = $c->db;

    my $sql = "SELECT * FROM tasks WHERE 1=1";
    my @params;

    if ($status) {
        $sql .= " AND status = ?";
        push @params, $status;
    }

    if ($q) {
        $sql .= " AND (title ILIKE ? OR description ILIKE ?)";
        push @params, "%$q%", "%$q%";
    }

    my $sth = $dbh->prepare($sql);
    $sth->execute(@params);

    my @tasks;
    while (my $row = $sth->fetchrow_hashref) {
        push @tasks, $row;
    }

    $c->render(template => 'tasks/index', tasks => \@tasks);
}

sub create {
    my ($c) = @_;

    my $title  = $c->param('title');
    my $desc   = $c->param('description');
    my $status = $c->param('status');

    unless ($title) {
        $c->flash(error => 'Title is required');
        return $c->redirect_to('/tasks');
    }

    my $sth = $c->db->prepare(
        'INSERT INTO tasks (title, description, status) VALUES (?, ?, ?)'
    );

    $sth->execute($title, $desc, $status);

    $c->flash(message => 'Task created');
    $c->redirect_to('/tasks');
}

sub update {
    my ($c) = @_;

    my $id     = $c->param('id');
    my $title  = $c->param('title');
    my $desc   = $c->param('description');
    my $status = $c->param('status');

    unless ($title) {
        $c->flash(error => 'Title cannot be empty');
        return $c->redirect_to('/tasks');
    }

    my $sth = $c->db->prepare(
        'UPDATE tasks SET title=?, description=?, status=? WHERE id=?'
    );

    $sth->execute($title, $desc, $status, $id);

    $c->flash(message => 'Task updated');
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