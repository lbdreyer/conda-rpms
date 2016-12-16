import unittest

from conda_rpms.generate import render_env


class Test_tag(unittest.TestCase):
    def check(self, tag, expected):
        config = {'install': {'prefix': '/data/local'},
                  'rpm': {'prefix': 'Tools'}
                  }
        r = render_env(branch_name='default', label='next', config=config,
                       tag=tag, commit_num=30)
        result_requires = [
            line for line in r.split('\n') if line.startswith('Requires: ')]
        self.assertEqual(result_requires, expected)

    def test_tag(self):
        self.check(tag='env-default-2016_12_15',
                   expected=['Requires: Tools-env-default-tag-2016_12_15'])

    def test_tag_with_count(self):
        self.check(tag='env-default-2016_12_15-2',
                   expected=['Requires: Tools-env-default-tag-2016_12_15-2'])


if __name__ == '__main__':
    unittest.main()
