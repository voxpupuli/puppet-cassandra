# cassandra::private::deprecation_warning
define cassandra::private::deprecation_warning($item_number,) {
  $item_name = $title
  $warning_message_1 = sprintf('%s has been deprecated and will be removed',
    $item_name)
  $warning_message_2 = 'in a future release.'
  $warning_message = "${warning_message_1} ${warning_message_2}"
  warning($warning_message)
  $dep_url = sprintf('https://github.com/locp/cassandra/wiki/DEP-%03d',
    $item_number)
  warning(sprintf('See %s for details.', $dep_url))
}
