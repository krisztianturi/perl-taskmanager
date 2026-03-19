package TaskManager::Controller::Tasks;
use Mojo::Base 'Mojolicious::Controller';

sub index {
    my ($c) = @_;

    my $user_id = $c->session('user_id');   # csak saját taskok
    my $status  = $c->param('status');
    my $q       = $c->param('q');
    my $dbh     = $c->db;

    my $sql = "SELECT * FROM tasks WHERE user_id = ?";
    my @params = ($user_id);

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

    my $title       = $c->param('title');
    my $description = $c->param('description');
    my $status      = $c->param('status');

    unless ($title) {
        $c->flash(error => 'Title is required');
        return $c->redirect_to('/tasks');
    }

    my $user_id = $c->session('user_id');

    my $sth = $c->db->prepare(
        "INSERT INTO tasks (title, description, status, user_id) VALUES (?, ?, ?, ?)"
    );
    $sth->execute($title, $description, $status, $user_id);

    $c->flash(message => 'Task created');
    $c->redirect_to('/tasks');
}

sub update {
    my ($c) = @_;

    my $id          = $c->param('id');
    my $title       = $c->param('title');
    my $description = $c->param('description');
    my $status      = $c->param('status');
    my $user_id     = $c->session('user_id');

    unless ($title) {
        $c->flash(error => 'Title cannot be empty');
        return $c->redirect_to('/tasks');
    }

    my $sth = $c->db->prepare(
        'UPDATE tasks SET title=?, description=?, status=? WHERE id=? AND user_id=?'
    );
    $sth->execute($title, $description, $status, $id, $user_id);

    $c->flash(message => 'Task updated');
    $c->redirect_to('/tasks');
}

sub delete {
    my ($c) = @_;
    my $id      = $c->param('id');
    my $user_id = $c->session('user_id');

    $c->db->do('DELETE FROM tasks WHERE id=? AND user_id=?', undef, $id, $user_id);

    $c->flash(message => 'Task deleted');
    $c->redirect_to('/tasks');
}
1;