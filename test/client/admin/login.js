var phantom, should;

should = require('should');

phantom = require('phantom');

describe('Server', function() {
  it("should load login page", function(done) {
    return phantom.create(function(ph) {
      return ph.createPage(function(page) {
        return page.open('http://localhost:8080/admin/login', function(s) {
          var fn;
          s.should.be.eql('success');
          fn = function() {
            var pass, user;
            user = $('input[name="username"]').size();
            pass = $('input[name="password"]').size();
            return {
              user: user,
              pass: pass
            };
          };
          return page.evaluate(fn, function(result) {
            result.user.should.be.exactly(1);
            result.pass.should.be.exactly(1);
            ph.exit();
            return done();
          });
        });
      });
    });
  });
  return it("should do login", function(done) {
    return phantom.create(function(ph) {
      return ph.createPage(function(page) {
        return page.open('http://localhost:8080/admin/login', function(s) {
          var checkResult, submitForm;
          s.should.be.eql('success');
          submitForm = function() {
            $('input[name="username"]').val('admin');
            $('input[name="password"]').val('passwd1');
            return $('button[type="submit"]').trigger('click');
          };
          checkResult = function() {
            return document.URL;
          };
          return page.evaluate(submitForm, function(result) {
            return page.evaluate(checkResult, function(result) {
              result.should.be.eql('http://localhost:8080/admin/dashboard');
              return done();
            });
          });
        });
      });
    });
  });
});
