#
# You may distribute this module under the same terms as perl itself

=pod 

=head1 NAME

  Bio::EnsEMBL::Hive::AnalysisJob

=head1 DESCRIPTION

  An AnalysisJob is the link between the input_id control data, the analysis and
  the rule system.  It also tracks the state of the job as it is processed

=head1 CONTACT

  Please contact ehive-users@ebi.ac.uk mailing list with questions/suggestions.

=head1 APPENDIX

  The rest of the documentation details each of the object methods.
  Internal methods are usually preceded with a _

=cut


package Bio::EnsEMBL::Hive::AnalysisJob;

use strict;

use Bio::EnsEMBL::Analysis;
use Bio::EnsEMBL::DBSQL::DBAdaptor;
use Bio::EnsEMBL::Hive::Worker;

sub new {
  my ($class,@args) = @_;
  my $self = bless {}, $class;
  return $self;
}

sub adaptor {
  my $self = shift;
  $self->{'_adaptor'} = shift if(@_);
  return $self->{'_adaptor'};
}

sub dbID {
  my $self = shift;
  $self->{'_dbID'} = shift if(@_);
  return $self->{'_dbID'};
}

sub input_id {
  my $self = shift;
  $self->{'_input_id'} = shift if(@_);
  return $self->{'_input_id'};
}

sub worker_id {
  my $self = shift;
  $self->{'_worker_id'} = shift if(@_);
  return $self->{'_worker_id'};
}

sub analysis_id {
  my $self = shift;
  $self->{'_analysis_id'} = shift if(@_);
  return $self->{'_analysis_id'};
}

sub job_claim {
  my $self = shift;
  $self->{'_job_claim'} = shift if(@_);
  return $self->{'_job_claim'};
}

sub status {
  my $self = shift;
  $self->{'_status'} = shift if(@_);
  return $self->{'_status'};
}

sub update_status {
  my ($self, $status ) = @_;
  return unless($self->adaptor);
  $self->status($status);
  $self->adaptor->update_status($self);
}

sub retry_count {
  my $self = shift;
  $self->{'_retry_count'} = shift if(@_);
  $self->{'_retry_count'} = 0 unless(defined($self->{'_retry_count'}));
  return $self->{'_retry_count'};
}

sub completed {
  my $self = shift;
  $self->{'_completed'} = shift if(@_);
  return $self->{'_completed'};
}

sub runtime_msec {
  my $self = shift;
  $self->{'_runtime_msec'} = shift if(@_);
  $self->{'_runtime_msec'} = 0 unless(defined($self->{'_runtime_msec'}));
  return $self->{'_runtime_msec'};
}

sub query_count {
  my $self = shift;
  $self->{'_query_count'} = shift if(@_);
  $self->{'_query_count'} = 0 unless(defined($self->{'_query_count'}));
  return $self->{'_query_count'};
}

sub semaphore_count {
  my $self = shift;
  $self->{'_semaphore_count'} = shift if(@_);
  $self->{'_semaphore_count'} = 0 unless(defined($self->{'_semaphore_count'}));
  return $self->{'_semaphore_count'};
}

sub semaphored_job_id {
  my $self = shift;
  $self->{'_semaphored_job_id'} = shift if(@_);
  return $self->{'_semaphored_job_id'};
}

sub stdout_file {
  my $self = shift;
  $self->{'_stdout_file'} = shift if(@_);
  return $self->{'_stdout_file'};
}

sub stderr_file {
  my $self = shift;
  $self->{'_stderr_file'} = shift if(@_);
  return $self->{'_stderr_file'};
}


=head2 autoflow

    Title   :  autoflow
    Function:  Gets/sets flag for whether the job should
               be automatically dataflowed on branch 1 when the job completes.
               If the subclass manually sends a job along branch 1 with dataflow_output_id,
               the autoflow will turn itself off.
    Returns :  boolean (1=default|0)

=cut

sub autoflow {
  my $self = shift;

  $self->{'_autoflow'} = shift if(@_);
  $self->{'_autoflow'} = 1 unless(defined($self->{'_autoflow'}));  

  return $self->{'_autoflow'};
}


##-----------------[indicators to the Worker]--------------------------------


sub lethal_for_worker {     # Job should set this to 1 prior to dying (or before running code that might cause death - such as RunnableDB's compilation)
                            # if it believes that the state of things will not allow the Worker to continue normally.
                            # The Worker will check the flag and commit suicide if it is set to true.
    my $self = shift;
    $self->{'_lethal_for_worker'} = shift if(@_);
    return $self->{'_lethal_for_worker'};
}

sub transient_error {       # Job should set this to 1 prior to dying (or before running code that might cause death)
                            # if it believes that it makes sense to retry the same job without any changes.
                            # It may also set it to 0 prior to dying (or before running code that might cause death)
                            # if it believes that there is no point in re-trying (say, if the parameters are wrong).
                            # The Worker will check the flag and make necessary adjustments to the database state.
    my $self = shift;
    $self->{'_transient_error'} = shift if(@_);
    return $self->{'_transient_error'};
}

sub incomplete {            # Job should set this to 0 prior to throwing if the job is done,
                            # but it wants the thrown message to be recorded with is_error=0.
    my $self = shift;
    $self->{'_incomplete'} = shift if(@_);
    return $self->{'_incomplete'};
}

##-----------------[/indicators to the Worker]-------------------------------

sub print_job {
  my $self = shift;
  my $logic_name = $self->adaptor()
      ? $self->adaptor->db->get_AnalysisAdaptor->fetch_by_dbID($self->analysis_id)->logic_name()
      : '';

  printf("job_id=%d %35s(%5d) retry=%d input_id='%s'\n", 
       $self->dbID,
       $logic_name,
       $self->analysis_id,
       $self->retry_count,
       $self->input_id);
}

1;
